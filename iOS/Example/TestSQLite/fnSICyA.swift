import Foundation
import SQLite3


class fnSICyA {
    let fm = FileManager.default

    var activePrintLog: Bool
    var isInitDBSQLite: Bool
    var isOpenDBSQLite: Bool
    
    private var dbSQLite: OpaquePointer? = nil
    private var filePathSQLite: String? = nil
    private var msgLog: String? = nil
    
    
    init() {
        #if DEBUG
        self.activePrintLog = true
        #else
        self.activePrintLog = false
        #endif
        
        self.isInitDBSQLite = false
        self.isOpenDBSQLite = false
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    

    func saveLogError(log pLog: String, printLog pActivePrint: Bool = false) {
        let fileName = getDocumentsDirectory().appendingPathComponent("ErrorLog").appendingPathExtension("txt")
        let formatDate = DateFormatter()
        var strLog: String

        formatDate.dateFormat = "yyyy/MM/dd HH:mm:ss"
        strLog = String(repeating: "-", count: 10) + "\r\n"
        strLog.append("Fecha: \(formatDate.string(from: Date()))\r\n")
        strLog.append("Log: \(pLog)\r\n")

        do {
            if fm.fileExists(atPath: fileName.path) {
                if let fileHandle = FileHandle(forWritingAtPath: fileName.path) {
                    let datos = Data(strLog.utf8)

                    defer {
                        fileHandle.closeFile()
                    }
                    
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(datos)
                    fileHandle.closeFile()
                }
                else {
                    try strLog.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
                }
            } else {
                try strLog.write(to: fileName, atomically: true, encoding: String.Encoding.utf8)
            }
        } catch (let error) {
            print("Error al grabar el Log. Error: \(error)")
        }
        
        if pActivePrint {
            print(pLog)
        }
    }

    
    func copyFileIntoDocumentsDirectory(pathOriginFile originFile: String, strFileName fileName: String) -> String {
        var pathFileName = getDocumentsDirectory().appendingPathComponent(fileName).path
        
        do {
            if fm.fileExists(atPath: pathFileName) {
                print("Existe un archivo anterior asi que va a tratar de borrarlo")
                try fm.removeItem(atPath: pathFileName)
            }
            
            try fm.copyItem(atPath: originFile, toPath: pathFileName)
        } catch (let error) {
            pathFileName = ""
            self.msgLog = "NO se pudo copiar el archivo \(fileName) a la carpeta \(pathFileName). Error: \(error)"

            saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
        }
        
        return pathFileName
    }
    
    
    func initDBSQLite(strFileName dbFileName: String) {
        let originalDBFile = Bundle.main.path(forResource: dbFileName, ofType: "db") ?? ""
        let fileName = dbFileName + "App.db"

        if fm.fileExists(atPath: originalDBFile) {
            let dbFilePath = copyFileIntoDocumentsDirectory(pathOriginFile: originalDBFile, strFileName: fileName)
            
            if dbFilePath.isEmpty {
                self.isInitDBSQLite = false
                saveLogError(log: "Error al inicializar la DB SQLite", printLog: self.activePrintLog)
            } else {
                self.isInitDBSQLite = true
                self.filePathSQLite = dbFilePath
            }
        } else {
            self.isInitDBSQLite = false
            saveLogError(log: "NO existe el archivo de la base de datos original!", printLog: self.activePrintLog)
        }
    }
    
    
    private func openDBSQLite() {
        var errorSQLite: Int32
        
        if self.isInitDBSQLite {
            if self.isOpenDBSQLite {
                errorSQLite = sqlite3_close(self.dbSQLite)
                
                if errorSQLite == SQLITE_OK {
                    self.isOpenDBSQLite = false
                    self.dbSQLite = nil
                } else {
                    self.msgLog = "NO se pudo cerrar la base de datos. Error:\(errorSQLite) - \(String(cString: sqlite3_errmsg(self.dbSQLite)))"
                    
                    saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
                }
            }

            errorSQLite = sqlite3_open(self.filePathSQLite, &dbSQLite)
            if errorSQLite == SQLITE_OK {
                self.isOpenDBSQLite = true
            } else {
                self.msgLog = "NO se pudo abrir la base de datos \(self.filePathSQLite!) SQLite. Error: \(errorSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))"
                
                saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
            }
        } else {
            saveLogError(log: "La base de datos SQLite no ha sido inicializada.", printLog: self.activePrintLog)
        }
    }
    
    
    func executeQueryDBSQLite(pQuery sqlQuery: String) -> Bool {
        var queryStatement: OpaquePointer? = nil
        var returnCodeSQLite: Int32
        var errorFound: Bool
        
        if !isOpenDBSQLite {
            self.openDBSQLite()
        }
        
        if isOpenDBSQLite {
            returnCodeSQLite = sqlite3_prepare_v2(dbSQLite, sqlQuery, -1, &queryStatement, nil)
            if returnCodeSQLite == SQLITE_OK {
                returnCodeSQLite = sqlite3_step(queryStatement)
                if returnCodeSQLite == SQLITE_DONE {
                    errorFound = false
                    print("El comando fue ejecutado!")
                } else {
                    errorFound = true
                    self.msgLog = "El comando NO se pudo ejecutar. Error:\(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))"
                    
                    saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
                }
                
                returnCodeSQLite = sqlite3_finalize(queryStatement)
                if returnCodeSQLite != SQLITE_OK {
                    self.msgLog = "NO se pudo resetear la instruccion. Error: \(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))"

                    saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
                }
            } else {
                errorFound = true
                saveLogError(log: "El comando \"\(returnCodeSQLite)\" no esta preparado. Error: \(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))", printLog: self.activePrintLog)
            }
            
            returnCodeSQLite = sqlite3_close(dbSQLite)
            if returnCodeSQLite != SQLITE_OK {
                self.msgLog = "NO se pudo cerrar la base de datos. Error:\(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(self.dbSQLite)))"
                saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
            }
        } else {
            errorFound = true
            saveLogError(log: "La base de datos NO esta abierta", printLog: self.activePrintLog)
        }
        
        return errorFound
    }
    
    
    func executeQueryResultDBSQLite(pQuery sqlQuery: String) -> [AnyHashable] {
        var queryStatement: OpaquePointer? = nil
        var arrData = [AnyHashable]()
        var arrRow: [AnyHashable] = []
        var returnCodeSQLite: Int32
        
        if !isOpenDBSQLite {
            self.openDBSQLite()
        }
        
        if isOpenDBSQLite {
            returnCodeSQLite = sqlite3_prepare_v2(dbSQLite, sqlQuery, -1, &queryStatement, nil)
            if returnCodeSQLite == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    arrRow = [AnyHashable]()
                    let totalColumns = sqlite3_column_count(queryStatement)
                
                    for i in 0..<totalColumns {
                        var dbDataAsChars: String
                        var dbDataAsInt: Int32
                        var dbDataAsInt64: Int64
                        var dbDataAsFloat: Double

                        switch sqlite3_column_bytes(queryStatement, i) {
                        case SQLITE_TEXT:
                            dbDataAsChars = String(cString: sqlite3_column_text(queryStatement, i))
                            arrRow.append(dbDataAsChars)
                        case  SQLITE_INTEGER:
                            dbDataAsInt = sqlite3_column_int(queryStatement, i)
                            arrRow.append(dbDataAsInt)
                        case SQLITE_INTEGER:
                            dbDataAsInt64 = sqlite3_column_int64(queryStatement, i)
                            arrRow.append(dbDataAsInt64)
                        case SQLITE_FLOAT:
                            dbDataAsFloat = sqlite3_column_double(queryStatement, i)
                            arrRow.append(dbDataAsFloat)
                        default:
                            dbDataAsChars = String(cString: sqlite3_column_text(queryStatement, i))
                            arrRow.append(dbDataAsChars)
                        }

//                        if arrColumnsName.count != totalColumns {
//                            dbDataAsChars = Int8(sqlite3_column_name(queryStatement, i))
//                            arrColumnsName.append(String(utf8String: dbDataAsChars) ?? "")
//                        }
                    }

                    if arrRow.count > 0 {
                        arrData.append(arrRow)
                    }
                }

                returnCodeSQLite = sqlite3_finalize(queryStatement)
                if returnCodeSQLite != SQLITE_OK {
                    self.msgLog = "NO se pudo resetear la instruccion. Error: \(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))"
                    saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
                }
            } else {
                arrData.removeAll()

                saveLogError(log: "El comando \"\(returnCodeSQLite)\" no esta preparado. Error: \(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))", printLog: self.activePrintLog)
            }
            
            returnCodeSQLite = sqlite3_close(dbSQLite)
            if returnCodeSQLite != SQLITE_OK {
                self.msgLog = "NO se pudo cerrar la base de datos. Error:\(returnCodeSQLite) - \(String(cString: sqlite3_errmsg(self.dbSQLite)))"
                saveLogError(log: self.msgLog!, printLog: self.activePrintLog)
            }
        } else {
            arrData.removeAll()
            saveLogError(log: "La base de datos NO esta abierta", printLog: self.activePrintLog)
        }
        
        return arrData
    }
}

//func createTable() {
//    var createTableStatement: OpaquePointer? = nil
//
////    if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
////        if sqlite3_step(createTableStatement) == SQLITE_DONE {
////            print("La tabla fue creada...")
////        } else {
////            print("La tabla no pudo ser creada...")
////        }
////    } else {
////        print("El comando CREATE TABLE no esta preparado...")
////    }
//}
//
//// let createTableString = """CREATE TABLE contactos (id INT PRIMARY KEY NOT NULL, nombre CHAR(100))"
//// createTable()
//
//func insertData() {
//
//}

                
//                while sqlite3_step(queryStatement) == SQLITE_ROW {
//                    let id = sqlite3_column_int(queryStatement, 0)
//                    let name = String(cString: sqlite3_column_text(queryStatement, 1))
//                    let powerrank = sqlite3_column_int(queryStatement, 2)
//
//                    //adding values to list
//                    heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
//                }



//        Forma de buscar el path de un directorio con NSSearch
//        let localPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let docDirectory = localPaths[0]

//        Forma de extraer el nombre del archivo de un URL
//        print("URL ErrorLog: \(fileName) \r\n Path ErrorLog: \(fileName.lastPathComponent)")
