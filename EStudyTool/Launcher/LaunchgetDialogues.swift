//
//  LaunchgetPatterns.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 4..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

class LaunchgetDialogues {
    
    var databasePath = NSString()
    var dialogueSempleList = [ESTDialogueProtocal]()
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createDialoguesDBTable() {
        
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
            if ESTFunctions().executeSqlFile(executeFile: "InsertDialogues") {
                // SQL 파일 실행 성공
                print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                
            } else {
                // SQL 파일 실행 실패
                print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
            }
            
        } else {
            print("[1] SQLite 파일 존재!!")
            
            // Dialouges 테이블이 있는지 확인한다.
            if ESTFunctions().existTableFromDB(searchTable: "DIALOGUES") {
                print("Dialogues 테이블 존재 확인")
                
            } else {
                // Patterns 테이블이 존재하지 않음 (초기 SQL 파일 실행)
                if ESTFunctions().executeSqlFile(executeFile: "InsertDialogues") {
                    print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                    
                } else {
                    // SQL 파일 실행 실패
                    print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
                }
            }
        }
        
        ESTGlobal.finishCreateDialoguesTable = true
    }
    
    // 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
    func checkDialoguesVersion() {
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version dialogues")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (versionData, response, error) -> Void in
                if error != nil {
                    print("[checkDialoguesVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = versionData {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["dialogues"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkDialoguesVersion] Different Dialogues Version")
                                
                                // 버전이 다르다면 Json 데이터로 업데이트 한다.
                                self.updateDialoguesFromJSON()
                                
                                // Plist의 버전 정보를 갱신한다.
                                PlistManager.sharedInstance.saveValue(value: Int(updateVersion) as AnyObject, forKey: "EST version dialogues")
                                
                            } else {
                                print("[checkDialoguesVersion] Same Dialogues Version")
                            }
                        }
                    }
                }
            }
            networkTask.resume()
            
        } else {
            print("[checkDialoguesVersion] : EST version dialogues is not exist in Info.plist")
        }
        
        ESTGlobal.finishDialoguesVersionCheck = true
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updateDialoguesFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Dialogues/updateDialogues.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[updateDialoguesFromJSON] fetch Failed: \(error?.localizedDescription)")

            } else {
                if let data = data {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 Dialogue가 있는지 확인한다.
                            if ESTFunctions().existItemFromDB(searchItem: item.1["title"].stringValue, searchTable: "DIALOGUES") {
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFromDB(updateItem: item.1["title"].stringValue, searchTable: "DIALOGUES", colum1: item.1["dialogue_en"].stringValue, colum2: item.1["dialogue_ko"].stringValue) {
                                    print("[updateDialoguesFromJSON] : Update Success!")
                                    
                                } else {
                                    print("[updateDialoguesFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                // 없다면 Insert (DIALOGUES : TITLE, DIALOGUE_EN, DIALOGUE_KO, DATE)
                                if ESTFunctions().insertItemFromDB(insertItem: item.1["title"].stringValue, searchTable: "DIALOGUES", colum1: item.1["dialogue_en"].stringValue, colum2: item.1["dialogue_ko"].stringValue, colum3: item.1["date"].stringValue) {
                                    print("[updateDialoguesFromJSON] : Insert Success!")
                                    
                                } else {
                                    print("[updateDialoguesFromJSON] : Insert Fail!")
                                }
                            }
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    // DB에서 Pattern 데이터를 불러온다.
    func getDialogueListFromDB() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            print("[getDialogueListFromDB] [1] Not Exist SQLite File!!")
            
        } else {
            let contactDB = FMDatabase(path: databasePath as String)
            if (contactDB?.open())! {
                
                let querySQL = "SELECT TITLE, DIALOGUE_EN FROM DIALOGUES WHERE TITLE != '';"
                let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                
                while results!.next() {
                    
                    let dialogue: ESTDialogueProtocal = ESTDialogueStruct(dialogueTitle: (results!.string(forColumn: "TITLE")), dialogue_en: (results!.string(forColumn: "DIALOGUE_EN")))
                    dialogueSempleList.append(dialogue)
                }
                
                // Json 데이터가 담겨있다면
                if dialogueSempleList.count > 0 {
                    ESTGlobal.dialougeSempleList = dialogueSempleList
                }
                
                contactDB?.close()
                
            } else {
                print("[6] Error : \(contactDB?.lastErrorMessage())")
            }
        }
        
        ESTGlobal.finishLoadDialogueData = true
    }

}
