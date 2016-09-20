//
//  WordMeamingViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 1..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit


class PatternsMeamingViewController: UIViewController {
    
    var selectedWord: ESTWordProtocal!
    
    // DB 경로
    var databasePath = NSString()
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meanTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWordFromDB(selectedWord.word)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sqlite에서 Word 데이터를 불러온다.
    func getWordFromDB(search: String) {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        databasePath = docsDir.stringByAppendingString("/estool.db")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if contactDB.open() {
            
            let querySQL = "SELECT WORD, MEANS_KO, MEANS_EN, READ, DATE FROM WORDS WHERE WORD = '\(search)'"
            // print("[Find from DB] SQL to find => \(querySQL)")
            
            let results:FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsInArray: nil)
            
            if results?.next() == true {
                wordLabel.text = results?.stringForColumn("WORD")
                
                // 영어 뜻이 있다면 보여주고 없다면 한글 뜻을 보여준다.
                if results?.stringForColumn("MEANS_EN") != "" {
                    meanTextView.text = results?.stringForColumn("MEANS_EN").stringByReplacingOccurrencesOfString("\\n", withString: "\r\r")
                    
                } else {
                    meanTextView.text = results?.stringForColumn("MEANS_KO").stringByReplacingOccurrencesOfString("\\n", withString: "\r\r")
                }
                
                
            } else {
                wordLabel.text = ""
                meanTextView.text = ""
            }
            
            contactDB.close()
        } else {
            print("[6] Error : \(contactDB.lastErrorMessage())")
        }
        
    }
    
    
    @IBAction func ViewMeanKo(sender: UIBarButtonItem) {
        ESTAlertView().alertwithCancle(fromController: self, setTitle: selectedWord.word, setNotice: selectedWord.means_ko.stringByReplacingOccurrencesOfString("\\n", withString: "\r"))
    }
    
    
    
}
