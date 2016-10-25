//
//  TreatQueryFromDB.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 8..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation

class ESTFunctions {
    
    // DB 경로
    var databasePath = NSString()
    
    // DB 쿼리에서 문자 변경
    func replaceQueryString(queryString: String) -> String {
        return queryString.replacingOccurrences(of: "'", with: "''")
    }
    
    // DB 테이블이 있는지 확인한다.
    func existTableFromDB(searchTable: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            print("[existTableFromDB] [6] Not Exist SQLite File!!")
            result = false
            
        } else {
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[existTableFromDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                var searchQuery: String = ""
                
                // search Table
                searchQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(searchTable)';"
                print("[existTableFromDB] [2] Query => \(searchQuery)")
                let results:FMResultSet? = contactDB?.executeQuery(searchQuery, withArgumentsIn: nil)
                
                if results?.next() == true {
                    print("[existTableFromDB] [3] exist search Table")
                    result = true
                    
                } else {
                    print("[existTableFromDB] [4] not exist search Table")
                    result = false
                }
                
                contactDB?.close()
            } else {
                
                print("[existTableFromDB] [5] Error : \(contactDB?.lastErrorMessage())")
            }
            
        }
        return result
    }
    
    // sql 파일을 불러와 실행시키다.
    func executeSqlFile(executeFile: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않는다면.
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            print("[executeSqlFile] [4] Not Exist SQLite File!!")
            result = false
            
        } else {
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[executeSqlFile] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                // SQL 파일 실행
                let insertPatternsFileUrl = Bundle.main.url(forResource: executeFile, withExtension: "sql")!
                let queries = try? String(contentsOf: insertPatternsFileUrl, encoding: String.Encoding.utf8)
                
                if let content = (queries){
                    let sqls = content.components(separatedBy: NSCharacterSet.newlines)
                    
                    // sql 파일의 쿼리를 한줄씩 읽어와서 실행한다.
                    for (index, sql) in sqls.enumerated() {
                        
                        if !(contactDB?.executeStatements(sql))! {
                            print("[executeSqlFile] [2] Error : \(contactDB?.lastErrorMessage())")
                            print("[error query] : \(sql)")
                            result = false
                            
                        } else {
                            // 입력하려는 전체 단어수와 실행된 수를 확인하다.
                            print("Insert by \(executeFile) : \(index) / \(sqls.count)")
                        }
                    }
                }
                
                contactDB?.close()
                result = true
                
            } else {
                print("[executeSqlFile] [3] Error : \(contactDB?.lastErrorMessage())")
                result = false
            }
            
        }
        return result
        
    }
    
    
    // DB에 검색하려는 단어/페턴이이 있는지 확인한다. (select)
    func existItemFromDB(searchItem: String, searchTable: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[existItemFormDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var searchQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS, DIALOGUES
                if searchTable == "WORDS" {
                    searchQuery = "SELECT WORD FROM \(searchTable) WHERE WORD = '\(searchItem)';"
                    
                } else if searchTable == "PATTERNS" {
                    searchQuery = "SELECT PATTERN FROM \(searchTable) WHERE PATTERN = '\(searchItem)';"
                
                } else if searchTable == "DIALOGUES" {
                    searchQuery = "SELECT TITLE FROM \(searchTable) WHERE TITLE = '\(searchItem)';"
                    
                } else {
                    print("[existItemFormDB] [2] Error : invalid Table name")
                    result = false
                }
                
                print("[existItemFormDB] [3] Query => \(searchQuery)")
                let results:FMResultSet? = contactDB?.executeQuery(searchQuery, withArgumentsIn: nil)
                
                if results?.next() == true {
                    print("[existItemFormDB] [4] exist search item")
                    result = true
                    
                } else {
                    print("[existItemFormDB] [5] not exist search item")
                    result = false
                }
                
                contactDB?.close()
            } else {
                
                print("[existItemFormDB] [6] Error : \(contactDB?.lastErrorMessage())")
            }

        } else {
            print("[existItemFormDB] [7] Not Exist SQLite File!!")
            result = false
        }
        return result
    }
    
    // DB에 단어와 뜻을 저장한다. (insert)
    // WORDS : MEANS_KO, MEANS_EN, DATE
    func insertItemFromDB(insertItem: String, searchTable: String, colum1: String, colum2: String, colum3: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[insertItemFormDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var insertQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS, DIALOGUES
                if searchTable == "WORDS" {
                    insertQuery = "INSERT INTO WORDS VALUES ('\(insertItem)', '\(colum1)', '\(colum2)', 0, '\(colum3)');"
                    
                } else if searchTable == "PATTERNS" {
                    insertQuery = "INSERT INTO PATTERNS VALUES ('\(insertItem)', '\(colum1)', '\(colum2)', 0, '\(colum3)');"
                    
                } else if searchTable == "DIALOGUES" {
                    insertQuery = "INSERT INTO DIALOGUES VALUES ('\(insertItem)', '\(colum1)', '\(colum2)', 0, '\(colum3)');"
                    
                } else {
                    print("[insertItemFormDB] [2] Error : invalid Table name")
                    result = false
                }

                print("[insertItemFormDB] [3] Query => \(insertQuery)")
                
                if (contactDB?.executeStatements(insertQuery))! {
                    print("[insertItemFormDB] [4] Success to Insert!")
                    result = true
                    
                } else {
                    print("[insertItemFormDB] [5] not exist search item")
                    result = false
                    
                }
                
                contactDB?.close()
            } else {
                
                print("[insertItemFormDB] [6] Error : \(contactDB?.lastErrorMessage())")
            }
            
        } else {
            print("[insertItemFormDB] [7] Not Exist SQLite File!")
            result = false
        }
        return result
    }
    
    // DB에 단어/페턴에 대한 내용을 수정한다. (update)
    // WORDS : MEANS_KO, MEANS_EN, DATE
    func updateItemFromDB(updateItem: String, searchTable: String, colum1: String, colum2: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        //databasePath = docsDir.stringByAppendingString("/estool.db")
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[updateItemFormDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var updateQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS, DIALOGUES
                if searchTable == "WORDS" {
                    updateQuery = "UPDATE WORDS SET MEANS_KO = '\(colum1)', MEANS_EN = '\(colum2)' WHERE WORD = '\(updateItem)';"
                    
                } else if searchTable == "PATTERNS" {
                    updateQuery = "UPDATE PATTERNS SET MEANS_KO = '\(colum1)', MEANS_EN = '\(colum2)' WHERE PATTERN = '\(updateItem)';"
                
                } else if searchTable == "DIALOGUES" {
                    updateQuery = "UPDATE DIALOGUES SET DIALOGUE_EN = '\(colum1)', DIALOGUE_KO = '\(colum2)' WHERE TITLE = '\(updateItem)';"
                    
                } else {
                    print("[updateItemFormDB] [2] Error : invalid Table name")
                    result = false
                }
                
                print("[updateItemFormDB] [3] Query => \(updateQuery)")
                
                if (contactDB?.executeUpdate(updateQuery, withArgumentsIn: nil))! {
                    print("[updateItemFormDB] [4] Success to Update!")
                    result = true
                    
                } else {
                    print("[updateItemFormDB] [5] Upfate Fail!")
                    result = false
                }
                
                contactDB?.close()
                
            } else {
                print("[updateItemFormDB] [6] Error : \(contactDB?.lastErrorMessage())")
            }
            
        } else {
            print("[insertItemFormDB] [7] Not Exist SQLite File!")
            result = false
        }
        return result
    }
    
    // 검색하려는 테이블의 데이터 카운드를 불러온다.
    func getItemCount(searchTable: String) -> Int32 {
        var result: Int32 = 0
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[existItemFormDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                var searchQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS, DIALOUGES
                if searchTable == "WORDS" {
                    searchQuery = "SELECT COUNT(*) AS AMOUNT FROM \(searchTable) WHERE WORD != '';"
                    
                } else if searchTable == "PATTERNS" {
                    searchQuery = "SELECT COUNT(*) AS AMOUNT FROM \(searchTable) WHERE PATTERN != '';"
                    
                } else if searchTable == "DIALOUGES" {
                    searchQuery = "SELECT COUNT(*) AS AMOUNT FROM \(searchTable) WHERE TITLE != '';"
                    
                } else {
                    print("[existItemFormDB] [2] Error : invalid Table name")
                }
                
                print("[existItemFormDB] [3] Query => \(searchQuery)")
                let results:FMResultSet? = contactDB?.executeQuery(searchQuery, withArgumentsIn: nil)
                
                if results?.next() == true {
                    print("[existItemFormDB] [4] exist search item")
                    result = (results?.int(forColumn: "AMOUNT"))!
                    
                    contactDB?.close()
                } else {
                    
                    print("[existItemFormDB] [6] Error : \(contactDB?.lastErrorMessage())")
                }
                
            } else {
                print("[existItemFormDB] [7] Not Exist SQLite File!!")
            }
            
        }
        return result
    }
    
    // DB에 단어/페턴에 대한 read count를 +1 한다. (update)
    func updateItemReadCountFromDB(updateItem: String, searchTable: String) -> Bool {
        var result: Bool = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[updateItemReadCountFromDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var updateQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS, DIALOGUES
                if searchTable == "WORDS" {
                    updateQuery = "UPDATE WORDS SET READ = READ +1 WHERE WORD = '\(replaceQueryString(queryString: updateItem))';"
                    
                } else if searchTable == "PATTERNS" {
                    updateQuery = "UPDATE PATTERNS SET READ = READ +1 WHERE PATTERN = '\(replaceQueryString(queryString: updateItem))';"
                    
                } else if searchTable == "DIALOGUES" {
                    updateQuery = "UPDATE DIALOGUES SET READ = READ +1 WHERE TITLE = '\(replaceQueryString(queryString: updateItem))';"
                    
                } else {
                    print("[updateItemReadCountFromDB] [2] Error : invalid Table name")
                    result = false
                }
                
                print("[updateItemReadCountFromDB] [3] Query => \(updateQuery)")
                
                if (contactDB?.executeUpdate(updateQuery, withArgumentsIn: nil))! {
                    print("[updateItemReadCountFromDB] [4] Success to Update!")
                    result = true
                    
                } else {
                    print("[updateItemReadCountFromDB] [5] Upfate Fail!")
                    result = false
                }
                
                contactDB?.close()
                
            } else {
                print("[updateItemReadCountFromDB] [6] Error : \(contactDB?.lastErrorMessage())")
            }
            
        } else {
            print("[updateItemReadCountFromDB] [7] Not Exist SQLite File!")
            result = false
        }
        return result
    }


}
