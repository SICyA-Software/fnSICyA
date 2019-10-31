import Foundation
import SQLite3


class fnSICyA {
    let fm = FileManager.default

    var isInitDBSQLite: Bool
    var isOpenDBSQLite: Bool
    
    private var dbSQLite: OpaquePointer? = nil
    private var filePathSQLite: String? = nil
    
    
    init() {
        self.isInitDBSQLite = false
        self.isOpenDBSQLite = false
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    

    func saveLogError(_ pLog: String) {
        let fileName = getDocumentsDirectory().appendingPathComponent("ErrorLog.txt")
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
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
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
            let dataLog = "NO se pudo copiar el archivo \(fileName) a la carpeta \(pathFileName). Error: \(error)"

            pathFileName = ""
            saveLogError(dataLog)
            print("str: ", dataLog)
            print("NO se pudo copiar el archivo \(fileName) a la carpeta \(pathFileName). Error: \(error)")
        }
        
        return pathFileName
    }
    
    
    func initDBSQLite(strFileName dbFileName: String) {
        let originalDBFile = Bundle.main.path(forResource: dbFileName, ofType: "db") ?? ""
        let fileName = dbFileName + "App.db"
        
        self.isInitDBSQLite = true
        
        if fm.fileExists(atPath: originalDBFile) {
            let dbFilePath = copyFileIntoDocumentsDirectory(pathOriginFile: originalDBFile, strFileName: fileName)
            
            if dbFilePath.isEmpty {
                self.isInitDBSQLite = false
                print("Error al inicializar la DBSQLite")
            } else {
                self.filePathSQLite = dbFilePath
            }
        } else {
            self.isInitDBSQLite = false
            print("NO existe el archivo de la base de datos original")
        }
    }
    
    
    private func openDBSQLite() {
        var errorSQLite: Int32
        
        if self.isInitDBSQLite {
            if self.isOpenDBSQLite {
                errorSQLite = sqlite3_close(dbSQLite)
                
                print("Valor SQL Close ", errorSQLite)
                if errorSQLite == SQLITE_OK {
                    self.isOpenDBSQLite = false
                    dbSQLite = nil
                }
            }

            errorSQLite = sqlite3_open(filePathSQLite, &dbSQLite)
            if errorSQLite == SQLITE_OK {
                self.isOpenDBSQLite = true
            } else {
                print("NO se pudo abrir la base de datos \(filePathSQLite ?? "N/A") SQLite. Error: \(errorSQLite)", String(cString: sqlite3_errmsg(dbSQLite)))
            }
        } else {
            print("La base de datos SQLite no ha sido iniciada")
        }
    }
    
    
    func executeQueryDBSQLite(pQuery sqlQuery: String) -> Bool {
        var queryStatement: OpaquePointer? = nil
        var errorSQLite: Int32
        var errorFound = false
        
        if !isOpenDBSQLite {
            self.openDBSQLite()
        }
        
        if isOpenDBSQLite {
            errorSQLite = sqlite3_prepare_v2(dbSQLite, sqlQuery, -1, &queryStatement, nil)

            if errorSQLite == SQLITE_OK {
                errorSQLite = sqlite3_step(queryStatement)
                if errorSQLite == SQLITE_DONE {
                    print("El comando fue ejecutado!")
                } else {
                    let errorLog = "El comando NO se pudo ejecutar. Error:\(errorSQLite) - \(String(cString: sqlite3_errmsg(dbSQLite)))"
                    saveLogError(errorLog)
                    print("El comando NO se pudo ejecutar. Error: \(errorSQLite) - ", String(cString: sqlite3_errmsg(dbSQLite)))
                }
            } else {
                print("El comando \"\(sqlQuery)\" no esta preparado. Error: \(errorSQLite) - ", String(cString: sqlite3_errmsg(dbSQLite)))
            }
        } else {
            errorFound = true
            print("La base de datos NO esta abierta")
        }
        
        sqlite3_reset(queryStatement)
        sqlite3_close(dbSQLite)
        
        return errorFound
    }
    
    
    func executeQueryResultDBSQLite(pQuery sqlQuery: String) -> [AnyHashable] {
        var arrDataRow: [AnyHashable] = []
        
        return arrDataRow
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

//        Forma de buscar el path de un directorio con NSSearch
//        let localPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let docDirectory = localPaths[0]

//        Forma de extraer el nombre del archivo de un URL
//        print("URL ErrorLog: \(fileName) \r\n Path ErrorLog: \(fileName.lastPathComponent)")
