//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON

// 단어 저장을 위한 타입을 만든다.
protocol ESTWordProtocal {
    var word: String {get set}
    var means_ko: String {get set}
}

struct ESTWordStruct: ESTWordProtocal {
    var word: String
    var means_ko: String
}

class WordsTableController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var WordsTableView: UITableView!
    
    var allWordData = [String: [ESTWordProtocal]]()
    //var WordDataBySwiftyJSON: JSON = []
    
    var wordSempleList = [ESTWordProtocal]()
    var sectionCount: Int = 0
    
    // DB 경로
    var databasePath = NSString()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [ESTWordProtocal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 로딩 이미지를 노출시킨다.
        ActivityModalView.shared.showActivityIndicator(view: self.view)

        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // check Words DB table
        createWordsDBTable()
        
        // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
        checkWordsVersion()
        
        // DB에서 Word 데이터를 불러온다.
        getWordListFromDB()
        
        let rowToselect: NSIndexPath = NSIndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: rowToselect as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        
        // 테이블 뷰 설정
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredWords = wordSempleList.filter({ word in
            // 영어 단어와 한글 뜻에서 검색어를 찾아 반환한다.
            return word.word.lowercased().contains(searchText.lowercased()) || word.means_ko.lowercased().contains(searchText.lowercased())
        })
        
        self.WordsTableView.reloadData()
    }
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createWordsDBTable() {
        //print("[1] 데이터베이스 시작")
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.appending("/estool.db") as NSString
        
        // db 파일이 존재하지 않을 경우
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            // FMDB 인스턴스를 이용하여 DB 체크
            let contactDB = FMDatabase(path:databasePath as String)
            if contactDB == nil {
                print("[1] Error : \(contactDB?.lastErrorMessage())")
            }
            
            // DB 오픈
            if (contactDB?.open())!{

                // Words 테이블 생성처리
                let insertWordsFileUrl = Bundle.main.url(forResource: "InsertWords", withExtension: "sql")!
                let queries = try? String(contentsOf: insertWordsFileUrl, encoding: String.Encoding.utf8)
                
                if let content = (queries){
                    let sqls = content.components(separatedBy: NSCharacterSet.newlines)
                    
                    // sql 파일의 쿼리를 한줄씩 읽어와서 실행한다.
                    for (index, sql) in sqls.enumerated() {
                        
                        if !(contactDB?.executeStatements(sql))! {
                            print("[2] Error : \(contactDB?.lastErrorMessage())")
                            
                        } else {
                            // 입력하려는 전체 단어수와 실행된 수를 확인하다.
                            print("\(index) / \(sqls.count)")
                        }
                    }
                }
                
                contactDB?.close()
            } else {
                print("[3] Error : \(contactDB?.lastErrorMessage())")
            }
        } else {
            print("[1] SQLite 파일 존재!!")
        }
    }

    // 버전을 확인한다. 버전이 다르다면 단어를 Insert 또는 Update 한다.
    func checkWordsVersion() {
        //print("[2] 버전체크 시작")
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "ESTversion words")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
                if error != nil {
                    print("[checkWordsVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = data {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["words"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkWordsVersion] : Different Words Version")
                                
                                // 버전이 다르다면 Json 데이토로 업데이트 한다.
                                self.updateWordsFromJSON()
                                
                            } else {
                                print("[checkWordsVersion] : Same Words Version")
                            }
                        }
                    }
                }
                
            }
            networkTask.resume()
            
        } else {
            print("[checkWordsVersion] : ESTversion words is not exist in Info.plist")
        }
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updateWordsFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Words/updateWords.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[updateWordsFromJSON] fetch Failed : \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 단어가 있는지 확인한다.
                            if ESTFunctions().existItemFormDB(searchItem: item.1["word"].stringValue, searchDB: "WORDS") {
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFormDB(updateItem: item.1["word"].stringValue, searchDB: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue) {
                                    // Update 성공
                                    print("[updateWordsFromJSON] : Update Success!")
                                } else {
                                    // Update 실패
                                    print("[updateWordsFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                
                                // 없다면 Insert
                                // WORDS : MEANS_KO, MEANS_EN, DATE
                                if ESTFunctions().insertItemFormDB(insertItem: item.1["word"].stringValue, searchDB: "WORDS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue, colum3: item.1["date"].stringValue) {
                                    // Insert 성공
                                    print("[updateWordsFromJSON] : Insert Success!")
                                } else {
                                    // Insert 실패
                                    print("[updateWordsFromJSON] : Insert Fail!")
                                }
                            }
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    // DB에서 Word 데이터를 불러온다.
    func getWordListFromDB() {
        //print("[3] 데이터베이스에서 단어 리스트를 불러 온다.")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let querySQL = "SELECT WORD, MEANS_KO FROM WORDS WHERE WORD != '';"
            let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            while results!.next() {
                
                if let word: ESTWordProtocal = ESTWordStruct(word: results!.string(forColumn: "WORD"), means_ko: results!.string(forColumn: "MEANS_KO")) {
                    wordSempleList.append(word)
                }
            }
            
            // Json 데이터가 담겨있다면
            if wordSempleList.count > 0 {
                
                // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                self.allWordData = self.alphabetizeArray(wordSempleList: wordSempleList)
            }
            
            contactDB?.close()
            self.WordsTableView.reloadData()
            
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }
    
    
    func alphabetizeArray(wordSempleList: [ESTWordProtocal]) -> [String: [ESTWordProtocal]] {
        var result = [String: [ESTWordProtocal]]()
        
        // 단어의 첫 글자를 기준으로 [String: [ESTWordStruct]] 형태로 다시 담는다.
        for item in wordSempleList {
            
            let index = item.word.startIndex.successor(in: item.word)
            let firstLetter = item.word.substring(to: index).uppercased()

            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
        }
        
        // 알파벳 순서로 정렬한다.
        for (key, value) in result {
            result[key] = value.sorted(by: { (a, b) -> Bool in
                a.word.lowercased() < b.word.lowercased()
            })
        }
        
        return result
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [ESTWordProtocal]]) -> [String] {
        let keys = sections.keys
        
        let sortedKeys = keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        return sortedKeys
    }
    
    // 검색 아이콘을 누르면 search Bar가 나온다.
    @IBAction func searchFocus(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    
    
    
    // Section의 수를 확인한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        //print("[TableView] Section의 수를 확인한다.")
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
            
        } else {
            let keys = self.allWordData.keys
            self.sectionCount = keys.count
            
            return keys.count
        }
    }
    
    // Section의 순서와 String을 확인한다.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //print("[TableView] Section의 순서와 String을 확인한다.")
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
            
        } else {
            let sortedKeys = getSortedKeys(sections: allWordData)
            return sortedKeys[section]
        }
    }
    
    // Section 단위의 테이블 수를 확인한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("[TableView] Section 단위의 테이블 수를 확인한다.")
        
        // 검색한 단어 수 리턴하기
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredWords.count
            
        } else {
            let sortedKeys = getSortedKeys(sections: allWordData)
            let key = sortedKeys[section]
            
            if let words = allWordData[key] {
                return words.count
            }
        }
        
        return 0
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("[TableView] Index에 해당하는 Row를 cell에 확인한다.")
        
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "myWordList")
        
        // 검색한 단어를 cell에 전달
        if searchController.isActive && searchController.searchBar.text != "" {
            let word = filteredWords[indexPath.row]
            cell.textLabel?.text = word.word
            
        } else {
            let keys = getSortedKeys(sections: allWordData)
            let key = keys[indexPath.section]
            
            if let words = allWordData[key] {
                let word = words[indexPath.row]
                cell.textLabel?.text = word.word
            }
        }
        
        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    // 왼쪽 Index에 표시할 [String]을 반환한다.
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let keys = allWordData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        // 단어를 검색한다면 Section Index를 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
            
        } else {
            return keys
        }
    }
    
    // 왼쪽 Index가 taped 되면 index의 string과 번호를 반환한다.
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return 0
            
        } else {
            return index
        }
    }
    
    // Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = allWordData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegue(withIdentifier: "goWordMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = allWordData[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegue(withIdentifier: "goWordMeaningView", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedWord: ESTWordProtocal!
        
        let keys = allWordData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        if (segue.identifier == "goWordMeaningView") {
            
            //
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.isActive && searchController.searchBar.text != "" {
                    selectedWord = filteredWords[indexPath.row]
                    
                } else {
                    let key = keys[indexPath.section]
                    if let words = allWordData[key] {
                        selectedWord = words[indexPath.row]
                    }
                }
            }
            
            let controller = segue.destination as? WordMeamingViewController
            controller!.selectedWord = selectedWord
        }
    }
}

extension WordsTableController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


