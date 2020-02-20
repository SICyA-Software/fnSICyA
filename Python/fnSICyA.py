import base64, json, csv, time, hashlib, xlwt

from os import path
from html.parser import HTMLParser
from datetime import datetime, date, timedelta


class fnSICyA:
    def __init__(self):
        pass


    def saveErrors(self, strError, pathLogs = None):
        dataError = []
        isSuccessful = False

        fileName = "log_" + datetime.now().strftime("%Y%m%d") + ".csv"
        if pathLogs != None:
            if path.isdir(pathLogs):
                fileName = pathLogs + "/" + fileName

        dataError.append(datetime.now().strftime("%Y-%m-%d  - %H:%M:%S"))
        dataError.append(strError)

        try:
            fileLog = open(fileName, "a")
            writer = csv.writer(fileLog)
            writer.writerow(dataError)

            isSuccessful = True
        except Exception as e:
            print("Error: ", str(e))
        finally:
            fileLog.close()

        return isSuccessful


    def generateMD5(self, strText):
        hashMD5 =  hashlib.md5(strText.encode('utf-8')).hexdigest()

        return hashMD5


# def encodeFileBase64(fileToEncode):
#     strEncode64 = ""

#     if path.isfile(fileToEncode):
#         try:
#             originalFile = open(fileToEncode, 'rb')
#             strEncode64 = str(base64.b64encode(originalFile.read()))
#             strEncode64 = strEncode64[2:len(strEncode64)-1]
#         except Exception as e:
#             saveErrors(str(e))

#     return strEncode64


# def unconvertUUID(nombreParametro, datos=None):
#     idKey = None
#     nombreParametro = str(nombreParametro)

#     if datos == None:
#         idKey = nombreParametro
#     else:
#         if nombreParametro in datos:
#             idKey = datos[nombreParametro]

#     if idKey != None:
#         idKey = idKey.replace("-", "")

#     return idKey


    def validTextHTML(self, strText):
        isHTML = False

        parser = HTMLParser()
        parser.feed(strText)
        tagHtml = parser.get_starttag_text()

        if tagHtml:
            isHTML = True

        return isHTML


# def mergeFileData(fileName, dataToMerge):
#     textFile = ""

#     if path.isfile(fileName):
#         try:
#             fileToText = open(fileName, "r")
#             for row in fileToText:
#                 textFile += row

#             for key, value in dataToMerge.items():
#                 if type(value) is not str:
#                     value = str(value)

#                 textFile = textFile.replace(key, value)
#         except Exception as e:
#             saveErrors(str(e))

#             print("Error Merge Function: ", str(e))

#     return textFile


    def convertFactorPercentFactor(self, value, typeConversion = None):
        valueReturn = value

        if valueReturn != None:
            if typeConversion == "P":
                print("entro a Porcentaje")
                valueReturn = value * 100
            elif typeConversion == "F":
                print("Entro a factor")
                valueReturn = value / 100
        else:
            valueReturn = 0

        return valueReturn


    def emptyToNone(self, param):
        if param == "" or param == 0:
            param = None

        return param


    def readJsonFile(sefl, fileName):
        dataJSON = None

        if path.isfile(fileName):
            try:
                jsonFile = open(fileName, "r")
                dataJSON = json.load(jsonFile)
                jsonFile.close()
            except Exception as e:
                saveErrors(str(e))

        return dataJSON


    def createJsonFile(self, fileName, dataJSON):
        pass


    def updateJsonFile(self, fileName, dataJSON):
        isSuccessful = False

        if path.isfile(fileName):
            try:
                jsonFile = open(fileName, "w+")
                jsonFile.write(json.dumps(dataJSON))
                jsonFile.close()

                isSuccessful = True
            except Exception as e:
                saveErrors(str(e))

        return isSuccessful

# def existInDict(nombreParametro, datos):
#     parametro = None
#     if nombreParametro in datos:
#         parametro = datos[nombreParametro]

#     return parametro


# def generateExcel(fileName, data):
#     fileName = pFileName
#     data = pData
#     ruta = os.getcwd()
#     wb = xlwt.Workbook(encoding='utf-8')
#     ws = wb.add_sheet('Reporte')
#     for row_num, registro in enumerate(data):
#         for col_num, key in enumerate(registro):
#             if row_num == 0 :
#                 ws.write(row_num, col_num, key.upper())
#             ws.write(row_num+1, col_num, registro[key])

#     wb.save(fileName)
#     ruta = ruta+"/"+fileName
#     xlsEncode64 = Encode64File(ruta)

#     return xlsEncode64
