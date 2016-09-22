//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON

// 패턴 저장을 위한 타입을 만든다.
protocol ESTPatternProtocal {
    var pattern: String {get set}
    var means_ko: String {get set}
}

struct ESTPatternStruct: ESTPatternProtocal {
    var pattern: String
    var means_ko: String
}

class PatternsTableController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var PatternsTableView: UITableView!
    
    var allPatternData = [String: [ESTPatternProtocal]]()
    var PatternDataBySwiftyJSON: JSON = []
    
    var patternSempleList = [ESTPatternProtocal]()
    var tableData = []
    var sectionCount: Int = 0
    //var words = [String]()
    
    // DB 경로
    var databasePath = NSString()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [ESTPatternProtocal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // 로딩 이미지를 노출시킨다.
        ActivityModalView.shared.showActivityIndicator(self.view)
        
        let rowToselect: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(rowToselect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
        checkPatternsVersion()
        
        // check Patterns DB table
        createPatternsDBTable()
        
        // DB에서 Word 데이터를 불러온다.
        getPatternListFromDB()
        
        
        // 테이블 뷰 설정
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
    func checkPatternsVersion() {
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey("ESTversion words")?.intValue {
            
            
            let mySession = NSURLSession.sharedSession()
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTaskWithURL(url) { (data, response, error) -> Void in
                if error != nil {
                    print("[checkVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = data {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["words"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkVersion] Different Version")
                                
                                // 버전이 다르다면 Json 데이토로 업데이트 한다.
                                self.updateWordsFromJSON()
                                
                            } else {
                                print("[checkVersion] Same Version")
                            }
                            
                            self.PatternsTableView.reloadData()
                        }
                    }
                }
                
            }
            networkTask.resume()
            
        } else {
            print("ESTversion words is not exist in Info.plist")
            
        }
    }
    
    
    // Json 데이터를 불러와 업데이트 한다.
    func updateWordsFromJSON() {
        
            let mySession = NSURLSession.sharedSession()
            let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/versionUpWords.json"
            let url: NSURL = NSURL(string: updateWordsUrl)!
        
            let networkTask = mySession.dataTaskWithURL(url) { (data, response, error) -> Void in
                if error != nil {
                    print("fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = data {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allUpdateWordsJSON = JSON(data: data)
                            
                            for item in allUpdateWordsJSON["voca"] {
                                
                                // DB를 검색해 단어가 있는지 확인한다.
                                if ESTFunctions().existItemFormDB(item.1["word"].stringValue, searchDB: "WORDS") {
                                    
                                    // 있다면 Update
                                    ESTFunctions().updateItemFormDB(item.1["word"].stringValue, searchDB: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue)
                                    
                                } else {
                                    
                                    // 없다면 Insert
                                    // WORDS : MEANS_KO, MEANS_EN, DATE
                                    ESTFunctions().insertItemFormDB(item.1["word"].stringValue, searchDB: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue, colum3: item.1["date"].stringValue)
                                }
                            }
                        }
                    }
                }
                
            }
            networkTask.resume()
    }
    
    
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createPatternsDBTable() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.stringByAppendingString("/estool.db")
        
        // db 파일이 존재하지 않을 경우
        let filemgr = NSFileManager.defaultManager()
        if !filemgr.fileExistsAtPath(databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[1] Error : \(contactDB.lastErrorMessage())")
            }
            
            // DB 오픈
            if contactDB.open(){
                // Words 테이블 생성처리
                //let sql_stmt = "CREATE TABLE IF NOT EXISTS WORDS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, WORD TEXT, MEANS_KO TEXT, MEANS_EN TEXT, READ INTEGER, DATE TEXT)"
                
                
                let insertWordsFileUrl = NSBundle.mainBundle().URLForResource("InsertWords", withExtension: "sql")!
                let queries = try? String(contentsOfURL: insertWordsFileUrl, encoding: NSUTF8StringEncoding)
                
                if let content = (queries){
                    let sqls = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                    
                    for sql in sqls {
                        
                        if !contactDB.executeStatements(sql) {
                            print("[2] Error : \(contactDB.lastErrorMessage())")
                        }
                    }
                }

                contactDB.close()
            } else {
                print("[3] Error : \(contactDB.lastErrorMessage())")
            }
        } else {
            print("[1] SQLite 파일 존재!!")
        }
    }
    
    
    
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredWords = patternSempleList.filter({ word in
            // 영어 단어와 한글 뜻에서 검색어를 찾아 반환한다.
            return word.word.lowercaseString.containsString(searchText.lowercaseString) || word.means_ko.lowercaseString.containsString(searchText.lowercaseString)
        })
        self.PatternsTableView.reloadData()
    }
    
    // 웹 URL을 통해 Json 데이터를 불러온다.
    func getWordListJson(JsonUrl: String) {
        
        let mySession = NSURLSession.sharedSession()
        let url: NSURL = NSURL(string: JsonUrl)!
        
        let networkTask = mySession.dataTaskWithURL(url) { (data, response, error) -> Void in
            if error != nil {
                print("fetch Failed: \(error?.localizedDescription)")
            } else {
                if let data = data {
                    do {

                        // json 데이터를 SwiftyJSON에 담는다.
                        self.PatternDataBySwiftyJSON = JSON(data: data)
                        //print(self.WordDataBySwiftyJSON)
                        
                        // Json 데이터가 담겨있다면
                        if self.PatternDataBySwiftyJSON.count > 0 {
                            
                            // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                            //self.allWordData = self.alphabetizeArray(self.WordDataBySwiftyJSON)
                            //print(self.allWordData)
                            
                            self.PatternsTableView.reloadData()
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    
    
    
    // DB에서 Word 데이터를 불러온다.
    func getPatternListFromDB() {
        
        let contactDB = FMDatabase(path: databasePath as String)
        if contactDB.open() {
            
            let querySQL = "SELECT WORD, MEANS_KO FROM WORDS"
            // print("[Find from DB] SQL to find => \(querySQL)")
            
            let results:FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsInArray: nil)
            
            while results!.next() {
                
                if let word: ESTPatternProtocal = ESTWordStruct(word: (results!.stringForColumn("WORD")), means_ko: (results!.stringForColumn("MEANS_KO"))) {
                    patternSempleList.append(word)
                }
            }
            
            // Json 데이터가 담겨있다면
            if patternSempleList.count > 0 {
                
                // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                self.allPatternData = self.alphabetizeArray(patternSempleList)
                //print(self.allWordData)
                
                self.PatternsTableView.reloadData()
            }
            
            //print(self.allWordData)
            
            contactDB.close()
            
        } else {
            print("[6] Error : \(contactDB.lastErrorMessage())")
        }
    }
    
    
    func alphabetizeArray(wordSempleList: [ESTPatternProtocal]) -> [String: [ESTPatternProtocal]] {
        var result = [String: [ESTPatternProtocal]]()
        
        // 단어의 첫 글자를 기준으로 [String: [ESTWordStruct]] 형태로 다시 담는다.
        for item in wordSempleList {
            let index = item.word.startIndex.advancedBy(1)
            let firstLetter = item.word.substringToIndex(index).uppercaseString
            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
        }
        
        // 알파벳 순서로 정렬한다.
        for (key, value) in result {
            result[key] = value.sort({ (a, b) -> Bool in
                a.word.lowercaseString < b.word.lowercaseString
            })
        }
        
        return result
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [ESTPatternProtocal]]) -> [String] {
        let keys = sections.keys
        let sortedKeys = keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        return sortedKeys
    }
    
    // Section의 수를 확인한다.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            return 1
            
        } else {
            let keys = self.allPatternData.keys
            self.sectionCount = keys.count

            return keys.count
        }
    }
    
    // Section의 순서와 String을 확인한다.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            return nil
            
        } else {
            let sortedKeys = getSortedKeys(allPatternData)
            return sortedKeys[section]
        }
    }
    
    // Section 단위의 테이블 수를 확인한다.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 검색한 단어 수 리턴하기
        if searchController.active && searchController.searchBar.text != "" {
            print("search count : \(filteredWords.count)")
            return filteredWords.count
            
        } else {
            let sortedKeys = getSortedKeys(allPatternData)
            let key = sortedKeys[section]
            
            if let words = allPatternData[key] {
                //print("section count : \(words.count)")
                return words.count
            }
        }
        
        return 0
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "myWordList")
        
        // 검색한 단어를 cell에 전달
        if searchController.active && searchController.searchBar.text != "" {
            let word = filteredWords[indexPath.row]
            cell.textLabel?.text = word.word
        } else {
            let keys = getSortedKeys(allPatternData)
            let key = keys[indexPath.section]
            if let words = allPatternData[key] {
                let word = words[indexPath.row]
                cell.textLabel?.text = word.word
            }
        }
        
        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    // 왼쪽 Index에 표시할 [String]을 반환한다.
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let keys = allPatternData.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        // 단어를 검색한다면 Section Index를 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            return nil
        } else {
            return keys
        }
    }
    
    // 왼쪽 Index가 taped 되면 index의 string과 번호를 반환한다.
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            return 0
            
        } else {
            //print("\(title) : \(index)")
            return index
        }
    }
    
    // Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let keys = allPatternData.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegueWithIdentifier("goWordMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = allPatternData[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegueWithIdentifier("goWordMeaningView", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selectedWord: ESTPatternProtocal!
        
        let keys = allPatternData.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        if (segue.identifier == "goWordMeaningView") {
            
            // 
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.active && searchController.searchBar.text != "" {
                    selectedWord = filteredWords[indexPath.row]
                    
                } else {
                    let key = keys[indexPath.section]
                    if let words = allPatternData[key] {
                        selectedWord = words[indexPath.row]
                    }
                }
            }
            
            let controller = segue.destinationViewController as? WordMeamingViewController
            controller!.selectedWord = selectedWord
        }
    }
    
}

extension PatternsTableController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

