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
    
    // DB에 검색하려는 단어/페턴이이 있는지 확인한다. (select)
    func existItemFormDB(searchItem: String, searchDB: String) -> Bool {
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
                print("[searchItemFromDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var searchQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS
                if searchDB == "WORDS" {
                    searchQuery = "SELECT WORD FROM \(searchDB) WHERE WORD = '\(searchItem)'"
                    
                } else if searchDB == "PATTERNS" {
                    searchQuery = "SELECT WORD FROM \(searchDB) WHERE PATTERN = '\(searchItem)'"
                    
                } else {
                    print("[searchItemFromDB] [2] Error : invalid Table name")
                    result = false
                }
                
                print("[searchItemFromDB] [3] Query => \(searchQuery)")
                let results:FMResultSet? = contactDB?.executeQuery(searchQuery, withArgumentsIn: nil)
                
                if results?.next() == true {
                    print("[searchItemFromDB] [4] exist search item")
                    result = true
                    
                } else {
                    print("[searchItemFromDB] [5] not exist search item")
                    result = false
                }
                
                contactDB?.close()
            } else {
                
                print("[searchItemFromDB] [6] Error : \(contactDB?.lastErrorMessage())")
            }

        } else {
            print("[searchItemFromDB] [7] Not Exist SQLite File!!")
            result = false
        }
        return result
    }
    
    // DB에 단어와 뜻을 저장한다. (insert)
    // WORDS : MEANS_KO, MEANS_EN, DATE
    func insertItemFormDB(insertItem: String, searchDB: String, colum1: String, colum2: String, colum3: String) -> Bool {
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
                print("[insertItemFormDB] [1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{
                
                var insertQuery: String = ""
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS
                if searchDB == "WORDS" {
                    insertQuery = "INSERT INTO WORDS VALUES ('\(insertItem)', '\(colum1)', '\(colum2)', 0, '\(colum3)')"
                    
                } else if searchDB == "PATTERNS" {
                    insertQuery = "INSERT INTO PATTERNS VALUES ('\(insertItem)', '\(colum1)', '\(colum2)', 0, '\(colum3)')"
                    
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
    func updateItemFormDB(updateItem: String, searchDB: String, colum1: String, colum2: String) -> Bool {
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
                
                // 테이블에 따라 분기 처리 : WORDS, PATTERNS
                if searchDB == "WORDS" {
                    updateQuery = "UPDATE WORDS SET MEANS_KO = '\(colum1)', MEANS_EN = '\(colum2)' WHERE WORD = '\(updateItem)'"
                    
                } else if searchDB == "PATTERNS" {
                    updateQuery = "UPDATE PATTERNS SET MEANS_KO = '\(colum1)', MEANS_EN = '\(colum2)' WHERE WORD = '\(updateItem)'"
                    
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

}
