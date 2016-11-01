//
//  LaunchgetParagraphes.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 31..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

class LaunchgetParagraphes {
    
    var databasePath = NSString()
    var paragraphSempleList = [ESTParagraphProtocal]()
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createParagraphesDBTable() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // SQL 파일을 실행한다.
            if ESTFunctions().executeSqlFile(executeFile: "InsertParagraphes") {
                print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                
            } else {
                print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
            }
            
        } else {
            print("[1] SQLite 파일 존재!!")
            
            // Paragraphes 테이블이 있는지 확인한다.
            if ESTFunctions().existTableFromDB(searchTable: "PARAGRAPHES") {
                print("Paragraphes 테이블 존재 확인")
                
            } else {
                // Paragraphes 테이블이 존재하지 않음 (초기 SQL 파일 실행)
                if ESTFunctions().executeSqlFile(executeFile: "InsertParagraphes") {
                    print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                    
                } else {
                    // SQL 파일 실행 실패
                    print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
                }
            }
        }
        
        ESTGlobal.finishCreateParagraphesTable = true
    }
    
    // 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
    func checkParagraphesVersion() {
        
        // Plist에서 paragraphes의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version paragraphes")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (versionData, response, error) -> Void in
                if error != nil {
                    print("[checkParagraphesVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = versionData {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["paragraphes"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkParagraphesVersion] Different Paragraphes Version")
                                
                                // 버전이 다르다면 Json 데이터로 업데이트 한다.
                                self.updateParagraphesFromJSON()
                                
                                // Plist의 버전 정보를 갱신한다.
                                PlistManager.sharedInstance.saveValue(value: Int(updateVersion) as AnyObject, forKey: "EST version paragraphes")
                                
                            } else {
                                print("[checkParagraphesVersion] Same Paragraphes Version")
                            }
                        }
                    }
                }
            }
            networkTask.resume()
            
        } else {
            print("[checkParagraphesVersion] : EST version paragraphes is not exist in Info.plist")
        }
        
        ESTGlobal.finishParagraphesVersionCheck = true
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updateParagraphesFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Paragraphes/updateParagraphes.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[updateParagraphesFromJSON] fetch Failed: \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 Paragraph가 있는지 확인한다.
                            if ESTFunctions().existItemFromDB(searchItem: item.1["title"].stringValue, searchTable: "PARAGRAPHES") {
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFromDB(updateItem: item.1["title"].stringValue, searchTable: "PARAGRAPHES", colum1: item.1["paragraph_en"].stringValue, colum2: item.1["paragraph_ko"].stringValue) {
                                    print("[updateParagraphesFromJSON] : Update Success!")
                                    
                                } else {
                                    print("[updateParagraphesFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                // 없다면 Insert (PARAGRAPHES : TITLE, PARAGRAPH_EN, PARAGRAPH_KO, DATE)
                                if ESTFunctions().insertItemFromDB(insertItem: item.1["title"].stringValue, searchTable: "PARAGRAPHES", colum1: item.1["paragraph_en"].stringValue, colum2: item.1["paragraph_ko"].stringValue, colum3: item.1["date"].stringValue) {
                                    print("[updateParagraphesFromJSON] : Insert Success!")
                                    
                                } else {
                                    print("[updateParagraphesFromJSON] : Insert Fail!")
                                }
                            }
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    // DB에서 Paragraph 데이터를 불러온다.
    func getParagraphListFromDB() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            print("[getParagraphListFromDB] [1] Not Exist SQLite File!!")
            
        } else {
            let contactDB = FMDatabase(path: databasePath as String)
            if (contactDB?.open())! {
                
                let querySQL = "SELECT TITLE, PARAGRAPH_EN FROM PARAGRAPH WHERE TITLE != '';"
                let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                
                while results!.next() {
                    
//                    if let paragraph: ESTParagraphProtocal = ESTParagraphStruct(paragraphTitle: (results!.string(forColumn: "TITLE")), paragraph_en: (results!.string(forColumn: "PARAGRAPH_EN"))) {
//                        paragraphSempleList.append(paragraph)
//                    }
                    
                    let paragraph: ESTParagraphProtocal = ESTParagraphStruct(paragraphTitle: (results!.string(forColumn: "TITLE")), paragraph_en: (results!.string(forColumn: "PARAGRAPH_EN")))
                    paragraphSempleList.append(paragraph)
                }
                
                
                // Json 데이터가 담겨있다면
                if paragraphSempleList.count > 0 {
                    ESTGlobal.paragraphSempleList = paragraphSempleList
                }
                
                contactDB?.close()
                
            } else {
                print("[6] Error : \(contactDB?.lastErrorMessage())")
            }
        }
        
        ESTGlobal.finishLoadDialogueData = true
    }
    
}

