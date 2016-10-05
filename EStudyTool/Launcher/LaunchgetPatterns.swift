//
//  LaunchgetPatterns.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 4..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

class LaunchgetPattern {
    
    // DB 경로
    var databasePath = NSString()
    
    var patternSempleList = [ESTPatternProtocal]()
    var allPatternData = [String: [ESTPatternProtocal]]()
    
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createPatternsDBTable() {
        //print("[1] 데이터베이스 시작")
        
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
            if ESTFunctions().executeSqlFile(executeFile: "InsertPatterns") {
                // SQL 파일 실행 성공
                print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                
            } else {
                // SQL 파일 실행 실패
                print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
            }
            
        } else {
            print("[1] SQLite 파일 존재!!")
            
            // Pattens 테이블이 있는지 확인한다.
            if ESTFunctions().existTableFromDB(searchTable: "PATTERNS") {
                // Patterns 테이블 존재 확인
                print("Patterns 테이블 존재 확인")
                
            } else {
                // Patterns 테이블이 존재하지 않음 (초기 SQL 파일 실행)
                if ESTFunctions().executeSqlFile(executeFile: "InsertPatterns") {
                    // SQL 파일 실행 성공
                    print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                    
                } else {
                    // SQL 파일 실행 실패
                    print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
                }
            }
        }
        
        ESTGlobal.finishCreatePatternsTable = true
    }
    
    // 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
    func checkPatternsVersion() {
        //print("[2] 버전체크 시작")
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "ESTversion patterns")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (versionData, response, error) -> Void in
                if error != nil {
                    print("[checkPatternsVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = versionData {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["patterns"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkPatternsVersion] Different Patternss Version")
                                
                                // 버전이 다르다면 Json 데이터로 업데이트 한다.
                                self.updatePatternsFromJSON()
                                
                            } else {
                                print("[checkPatternsVersion] Same Patterns Version")
                            }
                        }
                    }
                }
                
            }
            networkTask.resume()
            
        } else {
            print("[checkPatternsVersion] : ESTversion words is not exist in Info.plist")
        }
        
        ESTGlobal.finishPatternVersionCheck = true
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updatePatternsFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Patterns/updatePatterns.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (patternData, response, error) -> Void in
            if error != nil {
                print("[updatePatternsFromJSON] fetch Failed: \(error?.localizedDescription)")
                
            } else {
                if let data = patternData {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 단어가 있는지 확인한다.
                            if ESTFunctions().existItemFormDB(searchItem: item.1["pattern"].stringValue, searchDB: "PATTERNS") {
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFormDB(updateItem: item.1["pattern"].stringValue, searchDB: "PATTERNS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue) {
                                    // Update 성공
                                    print("[updatePatternsFromJSON] : Update Success!")
                                } else {
                                    // Update 실패
                                    print("[updatePatternsFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                // 없다면 Insert (PATTERN : MEANS_KO, MEANS_EN, DATE)
                                if ESTFunctions().insertItemFormDB(insertItem: item.1["pattern"].stringValue, searchDB: "PATTERNS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue, colum3: item.1["date"].stringValue) {
                                    // Insert 성공
                                    print("[updatePatternsFromJSON] : Insert Success!")
                                } else {
                                    // Insert 실패
                                    print("[updatePatternsFromJSON] : Insert Fail!")
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
    func getPatternListFromDB() {
        //print("[3] 데이터베이스에서 단어 리스트를 불러 온다.")
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            print("[getWordListFromDB] [1] Not Exist SQLite File!!")
            
        } else {
            let contactDB = FMDatabase(path: databasePath as String)
            if (contactDB?.open())! {
                
                let querySQL = "SELECT PATTERN, MEANS_KO FROM PATTERNS WHERE PATTERN != '';"
                let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                
                while results!.next() {
                    
                    if let pattern: ESTPatternProtocal = ESTPatternStruct(pattern: (results!.string(forColumn: "PATTERN")), means_ko: (results!.string(forColumn: "MEANS_KO"))) {
                        patternSempleList.append(pattern)
                    }
                }
                
                // Json 데이터가 담겨있다면
                if patternSempleList.count > 0 {
                    
                    // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                    ESTGlobal.allPatternData = self.alphabetizeArray(patternSempleList: patternSempleList)
                }
                
                contactDB?.close()
                
            } else {
                print("[6] Error : \(contactDB?.lastErrorMessage())")
            }
        }
        
        ESTGlobal.finishLoadPatternData = true
    }
    
    
    func alphabetizeArray(patternSempleList: [ESTPatternProtocal]) -> [String: [ESTPatternProtocal]] {
        var result = [String: [ESTPatternProtocal]]()
        var counter = 0
        
        // 패턴의 첫 글자를 기준으로 [String: [ESTPatternStruct]] 형태로 다시 담는다.
        counter = 1
        for item in patternSempleList {
            
            let index = item.pattern.startIndex.successor(in: item.pattern)
            let firstLetter = item.pattern.substring(to: index).uppercased()
            
            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
            
            print("restruct : \(counter) \(patternSempleList.count)")
            counter += 1
        }
        
        // 알파벳 순서로 정렬한다.
        counter = 1
        for (key, value) in result {
            result[key] = value.sorted(by: { (a, b) -> Bool in
                a.pattern.lowercased() < b.pattern.lowercased()
            })
            
            print("pattern sort : \(counter) \(result.count)")
            counter += 1
        }
        
        return result
    }


}
