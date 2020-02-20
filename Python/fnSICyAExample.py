from fnSICyA import fnSICyA

if __name__ == "__main__":
    fnS3 = fnSICyA()

    print("Creacion del archivo Log fue ",
          "Existosa" if fnS3.saveErrors("Hola Mundo!") else "Errada")
    print("Llave MD5 para \"Hola Mundo\" es: ", fnS3.generateMD5("Hola Mundo"))
    print("El texto <h1>Hola mundo!</h1> es ",
          "HTML" if fnS3.validTextHTML("<h1>Hola mundo!</h1>") else "text")
    print("Factor 5: ", fnS3.convertFactorPercentFactor(5, "F"))
    print("Porcentaje de 0.5: {}%".format(
        fnS3.convertFactorPercentFactor(0.5, "P")))

    fnS3.readJsonFile("Maria.json")
