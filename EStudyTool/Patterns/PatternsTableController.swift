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
    //var WordDataBySwiftyJSON: JSON = []
    
    var patternSempleList = [ESTPatternProtocal]()
    var sectionCount: Int = 0
    
    // DB 경로
    var databasePath = NSString()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [ESTPatternProtocal]()
    
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
        
        // 패턴 DB가 있는지 확인한다. (없다면 말들고 패턴을 입력한다.)
        createPatternsDBTable()
        
        // 패턴 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
        checkPatternsVersion()
        
        // 패턴 DB에서 패턴 데이터를 불러온다.
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
        filteredWords = patternSempleList.filter({ pattern in
            // 영어 패턴과 한글 뜻에서 검색어를 찾아 반환한다.
            return pattern.pattern.lowercased().contains(searchText.lowercased()) || pattern.means_ko.lowercased().contains(searchText.lowercased())
        })
        
        self.PatternsTableView.reloadData()
    }
    
    // 애플리케이션이 실행되면 데이터베이스 파일이 존재하는지 체크한다. 존재하지 않으면 데이터베이스파일과 테이블을 생성한다.
    func createPatternsDBTable() {
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
            
            // SQL 파일을 실행한다.
            if ESTFunctions().executeSqlFile(executeFile: "InsertPatterns") {
                // SQL 파일 실행 성공
                print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                
            } else {
                // SQL 파일 실행 실패
                print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
            }
            
        } else {
            print("[1] SQLite 파일 존재!!")
            
            // Pattens 테이블이 있는지 확인한다.
            if ESTFunctions().existTableFromDB(searchTable: "PATTERNS") {
                // Patterns 테이블 존재 확인
                print("Patterns 테이블 존재 확인")
                
            } else {
                // Patterns 테이블이 존재하지 않음 (초기 SQL 파일 실행)
                if ESTFunctions().executeSqlFile(executeFile: "InsertPatterns") {
                    // SQL 파일 실행 성공
                    print("SQL 파일 실행 성공: 초기 데이터 입력 완료")
                    
                } else {
                    // SQL 파일 실행 실패
                    print("SQL 파일 실행 샐패: 초기 데이터 입력 실패")
                }
                
            }
        }
    }

    // 버전을 확인한다. 버전이 다르다면 패턴을 Insert 또는 Update 한다.
    func checkPatternsVersion() {
        //print("[2] 버전체크 시작")
        
        // Plist에서 words의 버전 정보를 가져온다.
        if let currentVersion = PlistManager.sharedInstance.getValueForKey(key: "ESTversion patterns")?.int32Value {
            
            let mySession = URLSession.shared
            let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/ESTversion.json"
            let url: NSURL = NSURL(string: versionUrl)!
            
            let networkTask = mySession.dataTask(with: url as URL) { (versionData, response, error) -> Void in
                if error != nil {
                    print("[checkPatternsVersion] fetch Failed: \(error?.localizedDescription)")
                    
                } else {
                    if let data = versionData {
                        do {
                            
                            // Json 타입의 버전 정보를 가져온다.
                            let allVersionInfoJSON = JSON(data: data)
                            let updateVersion = allVersionInfoJSON["ESTversion"]["patterns"].int32!
                            
                            // Plist의 정보와 Json의 정보가 다르다면
                            if updateVersion != currentVersion {
                                print("[checkPatternsVersion] Different Patternss Version")
                                
                                // 버전이 다르다면 Json 데이터로 업데이트 한다.
                                self.updatePatternsFromJSON()
                                
                            } else {
                                print("[checkPatternsVersion] Same Patterns Version")
                            }
                        }
                    }
                }
                
            }
            networkTask.resume()
            
        } else {
            print("[checkPatternsVersion] : ESTversion words is not exist in Info.plist")
        }
    }
    
    // Json 데이터를 불러와 업데이트 한다.
    func updatePatternsFromJSON() {
        
        let mySession = URLSession.shared
        let updateWordsUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Patterns/updatePatterns.json"
        let url: NSURL = NSURL(string: updateWordsUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (patternData, response, error) -> Void in
            if error != nil {
                print("[updatePatternsFromJSON] fetch Failed: \(error?.localizedDescription)")
                
            } else {
                if let data = patternData {
                    do {
                        // Json 타입의 버전 정보를 가져온다.
                        let allUpdateWordsJSON = JSON(data: data)
                        
                        for item in allUpdateWordsJSON["voca"] {
                            
                            // DB를 검색해 단어가 있는지 확인한다.
                            if ESTFunctions().existItemFormDB(searchItem: item.1["pattern"].stringValue, searchDB: "PATTERNS") {
                                print("------> \(item.1["pattern"].stringValue)")
                                
                                // 있다면 Update
                                if ESTFunctions().updateItemFormDB(updateItem: item.1["pattern"].stringValue, searchDB: "PATTERNS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue) {
                                    // Update 성공
                                    print("[updatePatternsFromJSON] : Update Success!")
                                } else {
                                    // Update 실패
                                    print("[updatePatternsFromJSON] : Update Fail!")
                                }
                                
                            } else {
                                // 없다면 Insert (PATTERN : MEANS_KO, MEANS_EN, DATE)
                                if ESTFunctions().insertItemFormDB(insertItem: item.1["pattern"].stringValue, searchDB: "PATTERNS", colum1: item.1["means_ko"].stringValue, colum2: item.1["means_en"].stringValue, colum3: item.1["date"].stringValue) {
                                    // Insert 성공
                                    print("[updatePatternsFromJSON] : Insert Success!")
                                } else {
                                    // Insert 실패
                                    print("[updatePatternsFromJSON] : Insert Fail!")
                                }
                            }
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    // DB에서 Pattern 데이터를 불러온다.
    func getWordListFromDB() {
        //print("[3] 데이터베이스에서 단어 리스트를 불러 온다.")
        
        let contactDB = FMDatabase(path: databasePath as String)
        if (contactDB?.open())! {
            
            let querySQL = "SELECT PATTERN, MEANS_KO FROM PATTERNS"
            let results: FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            while results!.next() {
                
                if let pattern: ESTPatternProtocal = ESTPatternStruct(pattern: (results!.string(forColumn: "PATTERN")), means_ko: (results!.string(forColumn: "MEANS_KO"))) {
                    patternSempleList.append(pattern)
                }
            }
            
            // Json 데이터가 담겨있다면
            if patternSempleList.count > 0 {
                
                // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                self.allPatternData = self.alphabetizeArray(patternSempleList: patternSempleList)
            }
            
            contactDB?.close()
            self.PatternsTableView.reloadData()
            
        } else {
            print("[6] Error : \(contactDB?.lastErrorMessage())")
        }
    }
    
    
    func alphabetizeArray(patternSempleList: [ESTPatternProtocal]) -> [String: [ESTPatternProtocal]] {
        var result = [String: [ESTPatternProtocal]]()
        
        // 패턴의 첫 글자를 기준으로 [String: [ESTPatternStruct]] 형태로 다시 담는다.
        for item in patternSempleList {
            
            let index = item.pattern.startIndex.successor(in: item.pattern)
            let firstLetter = item.pattern.substring(to: index).uppercased()

            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
        }
        
        // 알파벳 순서로 정렬한다.
        for (key, value) in result {
            result[key] = value.sorted(by: { (a, b) -> Bool in
                a.pattern.lowercased() < b.pattern.lowercased()
            })
        }
        
        return result
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [ESTPatternProtocal]]) -> [String] {
        let keys = sections.keys
        
        let sortedKeys = keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        return sortedKeys
    }
    
    
    // Section의 수를 확인한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        //print("[TableView] Section의 수를 확인한다.")
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
            
        } else {
            let keys = self.allPatternData.keys
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
            let sortedKeys = getSortedKeys(sections: allPatternData)
            return sortedKeys[section]
        }
    }
    
    // Section 단위의 테이블 수를 확인한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("[TableView] Section 단위의 테이블 수를 확인한다.")
        
        // 검색한 패턴 수 리턴하기
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredWords.count
            
        } else {
            let sortedKeys = getSortedKeys(sections: allPatternData)
            let key = sortedKeys[section]
            
            if let words = allPatternData[key] {
                return words.count
            }
        }
        
        return 0
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("[TableView] Index에 해당하는 Row를 cell에 확인한다.")
        
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "myPatternList")
        
        // 검색한 패턴을 cell에 전달
        if searchController.isActive && searchController.searchBar.text != "" {
            let word = filteredWords[indexPath.row]
            cell.textLabel?.text = word.pattern
            
        } else {
            let keys = getSortedKeys(sections: allPatternData)
            let key = keys[indexPath.section]
            
            if let patterns = allPatternData[key] {
                let pattern = patterns[indexPath.row]
                cell.textLabel?.text = pattern.pattern
            }
        }
        
        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    // 왼쪽 Index에 표시할 [String]을 반환한다.
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let keys = allPatternData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        // 패턴을 검색한다면 Section Index를 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
            
        } else {
            return keys
        }
    }
    
    // 왼쪽 Index가 taped 되면 index의 string과 번호를 반환한다.
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        // 패턴을 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return 0
            
        } else {
            return index
        }
    }
    
    // Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = allPatternData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        // 패턴을 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegue(withIdentifier: "goPatternMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = allPatternData[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegue(withIdentifier: "goPatternMeaningView", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedPattern: ESTPatternProtocal!
        
        let keys = allPatternData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        if (segue.identifier == "goPatternMeaningView") {
            
            //
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.isActive && searchController.searchBar.text != "" {
                    selectedPattern = filteredWords[indexPath.row]
                    
                } else {
                    let key = keys[indexPath.section]
                    if let patterns = allPatternData[key] {
                        selectedPattern = patterns[indexPath.row]
                    }
                }
            }
            
            let controller = segue.destination as? PatternMeamingViewController
            controller!.selectedPattern = selectedPattern
        }
    }
}

extension PatternsTableController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



