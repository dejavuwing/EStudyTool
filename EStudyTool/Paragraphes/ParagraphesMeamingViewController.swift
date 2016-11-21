//
//  WordMeamingViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 1..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class ParagraphesMeamingViewController: UIViewController {
    
    var selectedParagraph: ESTParagraphProtocal!

    // DB 경로
    var databasePath = NSString()
    
    @IBOutlet weak var paragraphLabel: UILabel!
    @IBOutlet weak var paragraphENView: UITextView!
    
    var paragraphTitle: String = ""
    var resultMeansKo: String = ""
    var resultMeansEn: String = ""
    
    var viewCount: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getParagraphFromDB(search: selectedParagraph.paragraphTitle)
        
        // 읽은 수를 +1 한다.
        if ESTFunctions().updateItemReadCountFromDB(updateItem: selectedParagraph.paragraphTitle, searchTable: "PARAGRAPHES") {
            print("plused read count.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sqlite에서 Word 데이터를 불러온다.
    func getParagraphFromDB(search: String) {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        databasePath = docsDir.appendingFormat("/estool.db")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let searchItem = search.replacingOccurrences(of: "'", with: "''")
            let querySQL = "SELECT TITLE, PARAGRAPH_EN, PARAGRAPH_KO, READ, DATE FROM PARAGRAPHES WHERE TITLE = '\(searchItem)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            if results?.next() == true {
                
                paragraphTitle = (results?.string(forColumn: "TITLE"))!
                resultMeansKo = (results?.string(forColumn: "PARAGRAPH_KO"))!
                resultMeansEn = (results?.string(forColumn: "PARAGRAPH_EN"))!
                viewCount = (results?.int(forColumn: "READ"))!
                
                print("view count : \(viewCount)")
                
                paragraphLabel.text = paragraphTitle
                
                
                //paragraphENView.text = results?.string(forColumn: "PARAGRAPH_EN").replacingOccurrences(of: "\\n", with: "\r\r")
                //paragraphENView.font = UIFont(name: ESTFontType.defaultTextFont.rawValue, size: CGFloat(ESTFontSize.defaultTextFontSize.rawValue))
                
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
                
                paragraphENView.attributedText = NSAttributedString(string: meanText, attributes: attributes as? [String : Any])
                


            } else {
                paragraphENView.text = ""
                paragraphENView.text = ""
            }
            
            contactDB?.close()
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
        
    }
    
    
    @IBAction func ViewMeanKo(sender: UIBarButtonItem) {
        ESTAlertView().alertwithCancle(fromController: self, setTitle: paragraphTitle, setNotice: resultMeansKo.replacingOccurrences(of: "\\n", with: "\r"))
        
    }
    
}
