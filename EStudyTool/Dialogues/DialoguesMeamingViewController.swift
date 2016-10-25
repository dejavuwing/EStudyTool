//
//  WordMeamingViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 1..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class DialoguesMeamingViewController: UIViewController {
    
    var selectedDialogue: ESTDialogueProtocal!
    
    // DB 경로
    var databasePath = NSString()
    
    @IBOutlet weak var dialogueLabel: UILabel!
    @IBOutlet weak var dialogueENView: UITextView!
    
    var viewCount: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDialogueFromDB(search: selectedDialogue.dialogueTitle)
        
        // 읽은 수를 +1 한다.
        if ESTFunctions().updateItemReadCountFromDB(updateItem: selectedDialogue.dialogueTitle, searchTable: "DIALOGUES") {
            print("plused read count.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sqlite에서 Word 데이터를 불러온다.
    func getDialogueFromDB(search: String) {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        databasePath = docsDir.appendingFormat("/estool.db")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let searchItem = search.replacingOccurrences(of: "'", with: "''")
            let querySQL = "SELECT TITLE, DIALOGUE_EN, DIALOGUE_KR, READ, DATE FROM DIALOGUES WHERE TITLE = '\(searchItem)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            if results?.next() == true {
                dialogueLabel.text = results?.string(forColumn: "TITLE")
                viewCount = (results?.int(forColumn: "READ"))!
                print("view count : \(viewCount)")
                
                dialogueENView.text = results?.string(forColumn: "DIALOGUE_EN").replacingOccurrences(of: "\\n", with: "\r\r")
                dialogueENView.font = UIFont(name: ESTFontType.defaultTextFont.rawValue, size: CGFloat(ESTFontSize.defaultTextFontSize.rawValue))

            } else {
                dialogueENView.text = ""
                dialogueENView.text = ""
            }
            
            contactDB?.close()
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
        
    }
    
    
    @IBAction func ViewMeanKo(sender: UIBarButtonItem) {
        //ESTAlertView().alertwithCancle(fromController: self, setTitle: selectedPattern.pattern, setNotice: selectedDialogue..replacingOccurrences(of: "\\n", with: "\r"))
        
    }
    
}
