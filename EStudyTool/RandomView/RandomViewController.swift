//
//  RandomViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 6..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

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
        
        // Font Size 변경
        //let currentFont = meanTextView.font
        //let fontName = currentFont?.fontName.components(separatedBy: "-").first
        //let newFont = UIFont(name: "\(fontName!)-Regular", size: 18)
        
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
                
                print("view count : \(viewCount)")
                
                ReadLabel.text = results?.string(forColumn: "WORD")
                
                // 영어 뜻이 있다면 보여주고 없다면 한글 뜻을 보여준다.
                if results?.string(forColumn: "MEANS_EN") != "" {
                    meanTextView.text = resultMeansEn.replacingOccurrences(of: "\\n", with: "\r\r")
                    meanTextView.font = UIFont(name: ESTFontType.defaultTextFont.rawValue, size: CGFloat(ESTFontSize.defaultTextFontSize.rawValue))
                    
                } else {
                    meanTextView.text = resultMeansKo.replacingOccurrences(of: "\\n", with: "\r\r")
                    meanTextView.font = UIFont(name: ESTFontType.defaultTextFont.rawValue, size: CGFloat(ESTFontSize.defaultTextFontSize.rawValue))
                }

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
        default:
            break;
        }
    }
    


    
}
