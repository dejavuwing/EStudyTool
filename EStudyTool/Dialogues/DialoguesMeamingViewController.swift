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
    
    var dialogueTitle: String = ""
    var resultMeansKo: String = ""
    var resultMeansEn: String = ""
    
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
            let querySQL = "SELECT TITLE, DIALOGUE_EN, DIALOGUE_KO, READ, DATE FROM DIALOGUES WHERE TITLE = '\(searchItem)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            if results?.next() == true {
                
                dialogueTitle = (results?.string(forColumn: "TITLE"))!
                resultMeansKo = (results?.string(forColumn: "DIALOGUE_KO"))!
                resultMeansEn = (results?.string(forColumn: "DIALOGUE_EN"))!
                viewCount = (results?.int(forColumn: "READ"))!
                
                print("view count : \(viewCount)")
                
                dialogueLabel.text = dialogueTitle
                
                let meanText = resultMeansEn.replacingOccurrences(of: "\\n", with: "\r")
                let fieldColor: UIColor = UIColor.black
                let fieldFont = UIFont(name: ESTFontType.defaultTextFont.rawValue, size: CGFloat(ESTFontSize.defaultTextFontSize.rawValue))
                let paraStyle = NSMutableParagraphStyle(); paraStyle.lineSpacing = 8.0
                let skew = 0.1
                
                let attributes: NSDictionary = [
                    NSForegroundColorAttributeName: fieldColor,
                     NSParagraphStyleAttributeName: paraStyle,
                        NSObliquenessAttributeName: skew,
                               NSFontAttributeName: fieldFont!
                ]
                
                dialogueENView.attributedText = NSAttributedString(string: meanText, attributes: attributes as? [String : Any])

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
        ESTAlertView().alertwithCancle(fromController: self, setTitle: dialogueTitle, setNotice: resultMeansKo.replacingOccurrences(of: "\\n", with: "\r"))
        
    }
    
}
