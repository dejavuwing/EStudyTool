//
//  RandomViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 6..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import Toast_Swift

class RandomViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var ReadSelector: UISegmentedControl!
    
    @IBOutlet weak var ReadLabel: UILabel!
    @IBOutlet weak var meanTextView: UITextView!
    
    // DB 경로
    var databasePath = NSString()
    var querySQL: String = ""
    
    var resultWord: String = ""
    var resultMeansKo: String = ""
    var resultMeansEn: String = ""

    var viewCount: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Plist에서 Segment 정보를 가져온다.
        if let segmentIndex = PlistManager.sharedInstance.getValueForKey(key: "EST selectedSegmentIndex")?.int32Value {
            ReadSelector.selectedSegmentIndex = Int(segmentIndex)
        }
        
        // 렌덤 데이터를 불러온다.
        getRandomReadFromDB()
        
        // TapGesture를 meanTextView에 연결한다. (화면을 탭했을 때의 액션 처리)
        let tap = UITapGestureRecognizer(target: self, action: #selector(getRandomReadFromDB))
        tap.numberOfTapsRequired = 2
        self.meanTextView.addGestureRecognizer(tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // sqlite에서 Word 데이터를 불러온다.
    func getRandomReadFromDB() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        databasePath = docsDir.appendingFormat("/estool.db")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            // segmented controller 선택에 따라 Word와 Pattern 쿼리 변경
            switch ReadSelector.selectedSegmentIndex
            {
            case 0:
                querySQL = "SELECT WORD AS WORD, MEANS_EN, MEANS_KO, READ, DATE FROM WORDS ORDER BY RANDOM() LIMIT 1;"
            case 1:
                querySQL = "SELECT PATTERN AS WORD, MEANS_EN, MEANS_KO, READ, DATE FROM PATTERNS ORDER BY RANDOM() LIMIT 1;"
            case 2:
                querySQL = "SELECT TITLE AS WORD, DIALOGUE_EN AS MEANS_EN, DIALOGUE_KO AS MEANS_KO, READ, DATE FROM DIALOGUES ORDER BY RANDOM() LIMIT 1;"
            case 3:
                querySQL = "SELECT TITLE AS WORD, PARAGRAPH_EN AS MEANS_EN, PARAGRAPH_KO AS MEANS_KO, READ, DATE FROM PARAGRAPHES ORDER BY RANDOM() LIMIT 1;"
            default:
                print("QUERY:  \(querySQL)")
                break
            }

            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            if results?.next() == true {
                
                resultWord = (results?.string(forColumn: "WORD"))!
                resultMeansKo = (results?.string(forColumn: "MEANS_KO"))!
                resultMeansEn = (results?.string(forColumn: "MEANS_EN"))!
                viewCount = (results?.int(forColumn: "READ"))!

                ReadLabel.text = resultWord
                
                // 영어 뜻이 있다면 보여주고 없다면 한글 뜻을 보여준다.
                if results?.string(forColumn: "MEANS_EN") != "" {

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
                    
                    meanTextView.attributedText = NSAttributedString(string: meanText, attributes: attributes as? [String : Any])

                } else {
                    
                    let meanText = resultMeansKo.replacingOccurrences(of: "\\n", with: "\r")

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
                    
                    meanTextView.attributedText = NSAttributedString(string: meanText, attributes: attributes as? [String : Any])

                }
                
                // toast
                var style = ToastStyle()
                style.messageColor = UIColor.white
                self.view.makeToast("read count : \(viewCount)",duration: 1.0, position: .bottom, style: style)
                // toggle queueing behavior
                ToastManager.shared.queueEnabled = false
                

            } else {
                ReadLabel.text = ""
                meanTextView.text = ""
            }
            
            contactDB?.close()
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
        
        // 읽은 수를 +1 한다.
        switch ReadSelector.selectedSegmentIndex {
        case 0:
            if ESTFunctions().updateItemReadCountFromDB(updateItem: resultWord, searchTable: "WORDS") {
            }
        case 1:
            if ESTFunctions().updateItemReadCountFromDB(updateItem: resultWord, searchTable: "PATTERNS") {
            }
        case 2:
            if ESTFunctions().updateItemReadCountFromDB(updateItem: resultWord, searchTable: "DIALOGUES") {
            }
        case 3:
            if ESTFunctions().updateItemReadCountFromDB(updateItem: resultWord, searchTable: "PARAGRAPHES") {
            }
        default:
            break
        }
    }
    
    // 한글뜻을 Alert창으로 띄운다.
    @IBAction func ViewMeanKo(_ sender: UIBarButtonItem) {
        ESTAlertView().alertwithCancle(fromController: self, setTitle: resultWord, setNotice: resultMeansKo.replacingOccurrences(of: "\\n", with: "\r"))
    }
    
    // Segment가 변경되면 저장한다.
    @IBAction func selectSeg(_ sender: UISegmentedControl) {
        // segmented controller 선택에 따라 Word와 Pattern 쿼리 변경
        switch ReadSelector.selectedSegmentIndex
        {
        case 0:
            PlistManager.sharedInstance.saveValue(value: 0 as AnyObject, forKey: "EST selectedSegmentIndex")
            getRandomReadFromDB()
        case 1:
            PlistManager.sharedInstance.saveValue(value: 1 as AnyObject, forKey: "EST selectedSegmentIndex")
            getRandomReadFromDB()
        case 2:
            PlistManager.sharedInstance.saveValue(value: 2 as AnyObject, forKey: "EST selectedSegmentIndex")
            getRandomReadFromDB()
        case 3:
            PlistManager.sharedInstance.saveValue(value: 3 as AnyObject, forKey: "EST selectedSegmentIndex")
            getRandomReadFromDB()
        default:
            break;
        }
    }
    


    
}
