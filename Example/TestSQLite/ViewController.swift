//
//  ViewController.swift
//  TestSQLite
//
//  Created by Javier A. Junca Barreto on 26/10/19.
//  Copyright © 2019 SICyA Software SAS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fnS3 = fnSICyA()
        fnS3.initDBSQLite(strFileName: "TestDB")
        
        let errorFoundSQLite = fnS3.executeQueryDBSQLite(pQuery: "select * from Usuarios")
//
//        print("Error Found in SQLite ", errorFoundSQLite)
    }
}
