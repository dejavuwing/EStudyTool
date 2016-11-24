//
//  LauncherViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 4..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import Toast_Swift

class LauncherViewController: UIViewController {
    
    @IBOutlet weak var finishCreateWordsTable: UILabel!
    @IBOutlet weak var finishWordsVersionCheck: UILabel!
    @IBOutlet weak var finishLoadWordData: UILabel!
    
    @IBOutlet weak var finishCreatePatternsTable: UILabel!
    @IBOutlet weak var finishPatternVersionCheck: UILabel!
    @IBOutlet weak var finishLoadPatternData: UILabel!
    
    @IBOutlet weak var finishCreateDialoguesTable: UILabel!
    @IBOutlet weak var finishDialogueVersionCheck: UILabel!
    @IBOutlet weak var finishLoadDialogueData: UILabel!
    
    @IBOutlet weak var finishCreateParagraphesTable: UILabel!
    @IBOutlet weak var finishParagraphVersionCheck: UILabel!
    @IBOutlet weak var finishLoadParagraphData: UILabel!
    
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
        
        self.finishCreateDialoguesTable.textColor = UIColor.lightGray
        self.finishDialogueVersionCheck.textColor = UIColor.lightGray
        self.finishLoadDialogueData.textColor = UIColor.lightGray
        
        self.finishCreateParagraphesTable.textColor = UIColor.lightGray
        self.finishParagraphVersionCheck.textColor = UIColor.lightGray
        self.finishLoadParagraphData.textColor = UIColor.lightGray
        
        self.finishLoadYoutubeChannelsData.textColor = UIColor.lightGray
        self.finishLoadWebSitesData.textColor = UIColor.lightGray
        
        // sqlite 파일을 만들고 버전을 확인한다.
        firstCrateSql()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.finishCreateWordsTable.blink(status: "start")
        
        // toast
        var style = ToastStyle()
        style.messageColor = UIColor.white
        self.view.makeToast("데이터 로딩중입니다. 잠시 기다려 주세요.",duration: 10.0, position: .bottom, style: style)
        
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dataLoad), userInfo: nil, repeats: true)
        
    }
    
    
    func dataLoad() {
        
        switch counter {
            
        case 0:
            // check Words DB table
            LaunchgetWords().createWordsDBTable()

            if ESTGlobal.finishCreateWordsTable {
                self.finishCreateWordsTable.blink(status: "stop")
                self.finishCreateWordsTable.textColor = UIColor.black
                self.finishCreateWordsTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishWordsVersionCheck.blink(status: "start")
            }
        
        case 1:
            // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
            LaunchgetWords().checkWordsVersion()
            
            if ESTGlobal.finishWordsVersionCheck {
                self.finishWordsVersionCheck.blink(status: "stop")
                self.finishWordsVersionCheck.textColor = UIColor.black
                self.finishWordsVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadWordData.blink(status: "start")
            }
            
        case 2:
            // DB에서 Word 데이터를 불러온다.
            LaunchgetWords().getWordListFromDB()
            
            if ESTGlobal.finishLoadWordData {
                self.finishLoadWordData.blink(status: "stop")
                self.finishLoadWordData.textColor = UIColor.black
                self.finishLoadWordData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishCreatePatternsTable.blink(status: "start")
            }
            
        case 3:
            // 패턴 DB가 있는지 확인한다. (없다면 말들고 패턴을 입력한다.)
            LaunchgetPattern().createPatternsDBTable()
            
            if ESTGlobal.finishCreatePatternsTable {
                self.finishCreatePatternsTable.blink(status: "stop")
                self.finishCreatePatternsTable.textColor = UIColor.black
                self.finishCreatePatternsTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishPatternVersionCheck.blink(status: "start")
            }
        case 4:
            // 패턴 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
            LaunchgetPattern().checkPatternsVersion()
            
            if ESTGlobal.finishPatternVersionCheck {
                self.finishPatternVersionCheck.blink(status: "stop")
                self.finishPatternVersionCheck.textColor = UIColor.black
                self.finishPatternVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadPatternData.blink(status: "start")
            
            }
        case 5:
            // 패턴 DB에서 패턴 데이터를 불러온다.
            LaunchgetPattern().getPatternListFromDB()
            
            if ESTGlobal.finishLoadPatternData {
                self.finishLoadPatternData.blink(status: "stop")
                self.finishLoadPatternData.textColor = UIColor.black
                self.finishLoadPatternData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishCreateDialoguesTable.blink(status: "start")
            }
            
        case 6:
            // 다이얼로그 DB가 있는지 확인한다. (없다면 말들고 다이얼로그를 입력한다.)
            LaunchgetDialogues().createDialoguesDBTable()
            
            if ESTGlobal.finishCreateDialoguesTable {
                self.finishCreateDialoguesTable.blink(status: "stop")
                self.finishCreateDialoguesTable.textColor = UIColor.black
                self.finishCreateDialoguesTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishDialogueVersionCheck.blink(status: "start")
            }
        case 7:
            // 다이얼로그 버전을 확인한다. 버전이 다르다면 다이얼로그fmf Insert 또는 Update 한다.
            LaunchgetDialogues().checkDialoguesVersion()
            
            if ESTGlobal.finishDialoguesVersionCheck {
                self.finishDialogueVersionCheck.blink(status: "stop")
                self.finishDialogueVersionCheck.textColor = UIColor.black
                self.finishDialogueVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadDialogueData.blink(status: "start")
                
            }
        case 8:
            // 다이얼로그 DB에서 다이얼로그 데이터를 불러온다.
            LaunchgetDialogues().getDialogueListFromDB()
            
            if ESTGlobal.finishLoadDialogueData {
                self.finishLoadDialogueData.blink(status: "stop")
                self.finishLoadDialogueData.textColor = UIColor.black
                self.finishLoadDialogueData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishCreateParagraphesTable.blink(status: "start")
            }
            
        case 9:
            // 파라그라프 DB가 있는지 확인한다. (없다면 말들고 다이얼로그를 입력한다.)
            LaunchgetParagraphes().createParagraphesDBTable()
            
            if ESTGlobal.finishCreateParagraphesTable {
                self.finishCreateParagraphesTable.blink(status: "stop")
                self.finishCreateParagraphesTable.textColor = UIColor.black
                self.finishCreateParagraphesTable.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishParagraphVersionCheck.blink(status: "start")
            }
        case 10:
            // 파라그라프 버전을 확인한다. 버전이 다르다면 다이얼로그fmf Insert 또는 Update 한다.
            LaunchgetParagraphes().checkParagraphesVersion()
            
            if ESTGlobal.finishParagraphesVersionCheck {
                self.finishParagraphVersionCheck.blink(status: "stop")
                self.finishParagraphVersionCheck.textColor = UIColor.black
                self.finishParagraphVersionCheck.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadParagraphData.blink(status: "start")
                
            }
        case 11:
            // 파라그라프 DB에서 다이얼로그 데이터를 불러온다.
            LaunchgetParagraphes().getParagraphListFromDB()
            
            if ESTGlobal.finishLoadParagraphData {
                self.finishLoadParagraphData.blink(status: "stop")
                self.finishLoadParagraphData.textColor = UIColor.black
                self.finishLoadParagraphData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadYoutubeChannelsData.blink(status: "start")
            }
            
        case 12:
            // ChannelList를 불러온다. (closure의 return 방법 확인)
            LaunchgetYoutubeChannel().getChannelListJSON() {(response) in
                LaunchgetYoutubeChannel().getChannelDetails(channells: response)
            }
            
            if ESTGlobal.finishLoadYoutubeChannels {
                self.finishLoadYoutubeChannelsData.blink(status: "stop")
                self.finishLoadYoutubeChannelsData.textColor = UIColor.black
                self.finishLoadYoutubeChannelsData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)
                
                self.finishLoadWebSitesData.blink(status: "start")
            }
            
        case 13:
            // WebSite 정보를 불러온다. (closure의 return 방법 확인)
            LaunchgetWebSite().getSiteListJSON() {(response) in
                ESTGlobal.webSiteDataArray = response
            }
            
            if ESTGlobal.finishLoadWebSites {
                self.finishLoadWebSitesData.blink(status: "stop")
                self.finishLoadWebSitesData.textColor = UIColor.black
                self.finishLoadWebSitesData.font = UIFont(name: "TrebuchetMS-Bold", size: 17)

            }
            
        case 14:
            // Words 테이블로 이동
            goStart()

        default:
            if counter == 14 {
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

extension UILabel {
    func blink(status: String) {
        
        if status == "start" {
            self.alpha = 0.0
            UIView.animate(withDuration: 0.4, //Time duration you want,
                delay: 0.0,
                options: [.curveEaseInOut, .autoreverse, .repeat],
                animations: { [weak self] in self?.alpha = 1.0 },
                completion: { [weak self] _ in self?.alpha = 1.0 })
        }
        else {
            self.alpha = 1.0
            self.layer.removeAllAnimations()
        }
    }
}


