//
//  LaunchgetWords'.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 4..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

// 단어 저장을 위한 타입을 만든다.
protocol ESTWordProtocal {
    var word: String {get set}
    var means_ko: String {get set}
}

struct ESTWordStruct: ESTWordProtocal {
    var word: String
    var means_ko: String
}

// 패턴 저장을 위한 타입을 만든다.
protocol ESTPatternProtocal {
    var pattern: String {get set}
    var means_ko: String {get set}
}

struct ESTPatternStruct: ESTPatternProtocal {
    var pattern: String
    var means_ko: String
}

// 다이얼로그를 저장을 위한 타입을 만든다.
protocol ESTDialogueProtocal {
    var dialogueTitle: String {get set}
    var dialogue_en: String {get set}
}

struct ESTDialogueStruct: ESTDialogueProtocal {
    var dialogueTitle: String
    var dialogue_en: String
}

// 패러그라프를 저장을 위한 타입을 만든다.
protocol ESTParagraphProtocal {
    var paragraphTitle: String {get set}
    var paragraph_en: String {get set}
}

struct ESTParagraphStruct: ESTParagraphProtocal {
    var paragraphTitle: String
    var paragraph_en: String
}

struct ESTGlobal {
    static var allWordData = [String: [ESTWordProtocal]]()
    static var wordSempleList = [ESTWordProtocal]()
    static var allPatternData = [String: [ESTPatternProtocal]]()
    static var patternSempleList = [ESTPatternProtocal]()
    static var dialougeSempleList = [ESTDialogueProtocal]()
    static var paragraphSempleList = [ESTParagraphProtocal]()
    
    static var channelsDataArray = [[String: String]]()
    static var webSiteDataArray = [[String: String]]()
    
    static var finishCreateWordsTable: Bool = false
    static var finishWordsVersionCheck: Bool = false
    static var finishLoadWordData: Bool = false
    
    static var finishCreatePatternsTable: Bool = false
    static var finishPatternVersionCheck: Bool = false
    static var finishLoadPatternData: Bool = false
    
    static var finishCreateDialoguesTable: Bool = false
    static var finishDialoguesVersionCheck: Bool = false
    static var finishLoadDialogueData: Bool = false
    
    static var finishCreateParagraphesTable: Bool = false
    static var finishParagraphesVersionCheck: Bool = false
    static var finishLoadParagraphData: Bool = false
    
    static var finishLoadYoutubeChannels: Bool = false
    static var finishLoadWebSites: Bool = false
}

// 폰트 스타일 지정
enum ESTFontType: String {
    case defaultTextFont = "Helvetica-Light"
}

// 폰트 크기 지정
enum ESTFontSize: Float {
    case defaultTextFontSize = 16
    
}

class LaunchgetWords {
    
    // DB 경로
    var databasePath = NSString()
    
    var allWordData = [String: [ESTWordProtocal]]()
    var wordSempleList = [ESTWordProtocal]()
    
    
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createWordsDBTable() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path: databasePath as String)
            if contactDB == nil {
                print("[1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // SQL 파일을 실행한다.
            if ESTFunctions().executeSqlFile(executeFile: "InsertWords") {
                // SQL 파일 실행 성공
                print("[2] SQL 파일 실행 성공: 초기 데이터 입력 완료")
                
            } else {
                // SQL 파일 실행 실패
                print("[3] SQL 파일 실행 실패: 초기 데이터 입력 실패")
            }
            
        } else {
            print("[4] SQLite 파일 존재!!")
            
            // Words 테이블이 있는지 확인한다.
            if ESTFunctions().existTableFromDB(searchTable: "WORDS") {
                // Words 테이블 존재 확인
                print("[5] Words 테이블 존재 확인")
                
            } else {
                // Words 테이블이 존재하지 않음 (초기 SQL 파일 실행)
                if ESTFunctions().executeSqlFile(executeFile: "InsertWords") {
                    // SQL 파일 실행 성공
                    print("[6] SQL 파일 실행 성공: 초기 데이터 입력 완료")
                    
                } else {
                    // SQL 파일 실행 실패
                    print("[7] SQL 파일 실행 실패: 초기 데이터 입력 실패")
                }
            }
        }
        
        ESTGlobal.finishCreateWordsTable = true
    }
    
    // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
    func checkWordsVersion() {
        //print("[2] 버전체크 시작")
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version words")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
                if error != nil {
                    print("[checkWordsVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = data {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["words"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkWordsVersion] : Different Words Version")
                                
                                // 버전이 다르다면 Json 데이토로 업데이트 한다.
                                self.updateWordsFromJSON()
                                
                                // Plist의 버전 정보를 갱신한다.
                                PlistManager.sharedInstance.saveValue(value: Int(updateVersion) as AnyObject, forKey: "EST version words")
                                
                            } else {
                                print("[checkWordsVersion] : Same Words Version")
                            }
                        }
                    }
                }
            }
            networkTask.resume()
            
        } else {
            print("[checkWordsVersion] : EST version words is not exist in Info.plist")
        }
        
        ESTGlobal.finishWordsVersionCheck = true
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updateWordsFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Words/updateWords.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[updateWordsFromJSON] fetch Failed : \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 단어가 있는지 확인한다.
                            if ESTFunctions().existItemFromDB(searchItem: item.1["word"].stringValue, searchTable: "WORDS") {
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFromDB(updateItem: item.1["word"].stringValue, searchTable: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue) {
                                    // Update 성공
                                    print("[updateWordsFromJSON] : Update Success!")
                                } else {
                                    // Update 실패
                                    print("[updateWordsFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                
                                // 없다면 Insert
                                // WORDS : MEANS_KO, MEANS_EN, DATE
                                if ESTFunctions().insertItemFromDB(insertItem: item.1["word"].stringValue, searchTable: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue, colum3: item.1["date"].stringValue) {
                                    // Insert 성공
                                    print("[updateWordsFromJSON] : Insert Success!")
                                } else {
                                    // Insert 실패
                                    print("[updateWordsFromJSON] : Insert Fail!")
                                }
                            }
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    // DB에서 Word 데이터를 불러온다.
    func getWordListFromDB() {
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
                
                let querySQL = "SELECT WORD, MEANS_KO FROM WORDS WHERE WORD != '';"
                let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
                
                while results!.next() {
                    
//                    if let word: ESTWordProtocal = ESTWordStruct(word: results!.string(forColumn: "WORD"), means_ko: results!.string(forColumn: "MEANS_KO")) {
//                        wordSempleList.append(word)
//                    }
                    
                    let word: ESTWordProtocal = ESTWordStruct(word: results!.string(forColumn: "WORD"), means_ko: results!.string(forColumn: "MEANS_KO"))
                    wordSempleList.append(word)
                }
                
                // Json 데이터가 담겨있다면
                if wordSempleList.count > 0 {
                    
                    // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                    ESTGlobal.allWordData = self.alphabetizeArray(wordSempleList: wordSempleList)
                    ESTGlobal.wordSempleList = wordSempleList
                }
                
                contactDB?.close()
                
            } else {
                print("[6] Error : \(contactDB?.lastErrorMessage())")
            }
        }
        
        ESTGlobal.finishLoadWordData = true
    }
    
    
    func alphabetizeArray(wordSempleList: [ESTWordProtocal]) -> [String: [ESTWordProtocal]] {
        var result = [String: [ESTWordProtocal]]()
        var counter = 0
        
        // 단어의 첫 글자를 기준으로 [String: [ESTWordStruct]] 형태로 다시 담는다.
        counter = 1
        for item in wordSempleList {
            
            let index = item.word.startIndex.successor(in: item.word)
            let firstLetter = item.word.substring(to: index).uppercased()
            
            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
            
            print("restruct : \(counter) \(wordSempleList.count)")
            counter += 1
        }
        
        // 알파벳 순서로 정렬한다.
        counter = 1
        for (key, value) in result {
            result[key] = value.sorted(by: { (a, b) -> Bool in
                a.word.lowercased() < b.word.lowercased()
            })
            
            print("word sort : \(counter) \(result.count)")
            counter += 1
        }
        
        return result
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [ESTWordProtocal]]) -> [String] {
        let keys = sections.keys
        
        let sortedKeys = keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        return sortedKeys
    }
    
}
