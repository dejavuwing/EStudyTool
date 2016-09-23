//
//  WordMeamingViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 1..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit


class PatternMeamingViewController: UIViewController {
    
    var selectedPattern: ESTPatternProtocal!
    
    // DB 경로
    var databasePath = NSString()
    
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var meanTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPatternFromDB(search: selectedPattern.pattern)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sqlite에서 Word 데이터를 불러온다.
    func getPatternFromDB(search: String) {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        databasePath = docsDir.appendingFormat("/estool.db")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let searchItem = search.replacingOccurrences(of: "'", with: "''")
            let querySQL = "SELECT PATTERN, MEANS_KO, MEANS_EN, READ, DATE FROM PATTERNS WHERE PATTERN = '\(searchItem)'"
            print("----->  \(querySQL)")
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            if results?.next() == true {
                patternLabel.text = results?.string(forColumn: "PATTERN")
                
                // 영어 뜻이 있다면 보여주고 없다면 한글 뜻을 보여준다.
                if results?.string(forColumn: "MEANS_EN") != "" {
                    meanTextView.text = results?.string(forColumn: "MEANS_EN").replacingOccurrences(of: "\\n", with: "\r\r")
                    
                } else {
                    meanTextView.text = results?.string(forColumn: "MEANS_KO").replacingOccurrences(of: "\\n", with: "\r\r")
                }
                
            } else {
                patternLabel.text = ""
                meanTextView.text = ""
            }
            
            contactDB?.close()
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
        
    }
    
    
    @IBAction func ViewMeanKo(sender: UIBarButtonItem) {
        ESTAlertView().alertwithCancle(fromController: self, setTitle: selectedPattern.pattern, setNotice: selectedPattern.means_ko.replacingOccurrences(of: "\\n", with: "\r"))
    }
    
}
