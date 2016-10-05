//
//  LauncherViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 4..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class LauncherViewController: UIViewController {
    
    @IBOutlet weak var finishCreateWordsTable: UILabel!
    @IBOutlet weak var finishWordsVersionCheck: UILabel!
    @IBOutlet weak var finishLoadWordData: UILabel!
    @IBOutlet weak var finishCreatePatternsTable: UILabel!
    @IBOutlet weak var finishPatternVersionCheck: UILabel!
    @IBOutlet weak var finishLoadPatternData: UILabel!
    @IBOutlet weak var finishLoadYoutubeChannelsData: UILabel!
    @IBOutlet weak var finishLoadWebSitesData: UILabel!
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.finishCreateWordsTable.textColor = UIColor.lightGray
        self.finishWordsVersionCheck.textColor = UIColor.lightGray
        self.finishLoadWordData.textColor = UIColor.lightGray
        self.finishCreatePatternsTable.textColor = UIColor.lightGray
        self.finishPatternVersionCheck.textColor = UIColor.lightGray
        self.finishLoadPatternData.textColor = UIColor.lightGray
        self.finishLoadYoutubeChannelsData.textColor = UIColor.lightGray
        self.finishLoadPatternData.textColor = UIColor.lightGray
        
        // sqlite 파일을 만들고 버전을 확인한다.
        firstCrateSql()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 타이머로 데이터를 로딩한다.
        loadTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var counter = 0
    var timer = Timer()
    

    
    func loadTimer() {
        
        // 타이머 시작
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dataLoad), userInfo: nil, repeats: true)
        
    }
    
    
    func dataLoad() {
        
        switch counter {
            
        case 0:
            // check Words DB table
            LaunchgetWords().createWordsDBTable()
            
            if ESTGlobal.finishCreateWordsTable {
                self.finishCreateWordsTable.textColor = UIColor.black
                self.finishCreateWordsTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
            }
        
        case 1:
            // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
            LaunchgetWords().checkWordsVersion()
            sleep(1)
            
            if ESTGlobal.finishWordsVersionCheck {
                self.finishWordsVersionCheck.textColor = UIColor.black
                self.finishWordsVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            }
            
        case 2:
            // DB에서 Word 데이터를 불러온다.
            LaunchgetWords().getWordListFromDB()
            sleep(3)
            
            if ESTGlobal.finishLoadWordData {
                self.finishLoadWordData.textColor = UIColor.black
                self.finishLoadWordData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishCreatePatternsTable.ru
            }
            
        case 3:
            // 패턴 DB가 있는지 확인한다. (없다면 말들고 패턴을 입력한다.)
            LaunchgetPattern().createPatternsDBTable()
            
            if ESTGlobal.finishCreatePatternsTable {
                self.finishCreatePatternsTable.textColor = UIColor.black
                self.finishCreatePatternsTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            }
        case 4:
            // 패턴 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
            LaunchgetPattern().checkPatternsVersion()
            sleep(1)
            
            if ESTGlobal.finishPatternVersionCheck {
                self.finishPatternVersionCheck.textColor = UIColor.black
                self.finishPatternVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            
            }
        case 5:
            // 패턴 DB에서 패턴 데이터를 불러온다.
            LaunchgetPattern().getPatternListFromDB()
            sleep(3)
            
            if ESTGlobal.finishLoadPatternData {
                self.finishLoadPatternData.textColor = UIColor.black
                self.finishLoadPatternData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            }
            
        case 6:
            // ChannelList를 불러온다. (closure의 return 방법 확인)
            LaunchgetWebSite().getSiteListJSON() {(response) in
                if let desiredSitesArray: [[String: String]] = response {
                    ESTGlobal.webSiteDataArray = desiredSitesArray
                }
            }
            
            if ESTGlobal.finishLoadWebSites {
                self.finishLoadYoutubeChannelsData.textColor = UIColor.black
                self.finishLoadYoutubeChannelsData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            }
            
        case 7:
            // WebSite 정보를 불러온다. (closure의 return 방법 확인)
            LaunchgetWebSite().getSiteListJSON() {(response) in
                if let desiredSitesArray: [[String: String]] = response {
                    ESTGlobal.webSiteDataArray = desiredSitesArray
                }
            }
            
            if ESTGlobal.finishLoadWebSites {
                self.finishLoadWebSitesData.textColor = UIColor.black
                self.finishLoadWebSitesData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
            }
            
        case 8:
            // Words 테이블로 이동
            goStart()

        default:
            if counter == 8 {
                // 타이머 종료
                timer.invalidate()
            }
        }
        counter += 1
    }
    



    
    
    func goStart() {
        performSegue(withIdentifier: "goStart", sender: nil)
    }
    
    // sqlite 파일을 만들고 버전을 확인한다.
    func firstCrateSql() {
        var databasePath = NSString()
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let querySQL = "select sqlite_version() AS version;"
            let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            while results!.next() {
                
                print("sqlite version : \(results!.string(forColumn: "version"))")
            }
            
            contactDB?.close()
            
        } else {
            print("[firstCrateSql] Error : \(contactDB?.lastErrorMessage())")
        }
    }
    
}

