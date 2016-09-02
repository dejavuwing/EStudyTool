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
protocol jakesWord {
    var word: String {get set}
    var means_ko: String {get set}
    var means_en: String {get set}
}

struct wordEl: jakesWord {
    var word: String
    var means_ko: String
    var means_en: String
}

// 단어 저장을 위한 타입을 만든다.
protocol ESTWordProtocal {
    var word: String {get set}
    var means_ko: String {get set}
    var means_en: String {get set}
    var date: String {get set}
}

struct ESTWordStruct: ESTWordProtocal {
    var word: String
    var means_ko: String
    var means_en: String
    var date: String
}

class WordsTableController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet var WordsTableView: UITableView!
    
    // sections --> allWordData 로 변경
    var allWordData = [String: [ESTWordProtocal]]()
    var WordDataBySwiftyJSON: JSON = []
    var wordSempleList = [ESTWordProtocal]()
    var tableData = []
    
    var sectionCount: Int = 0
    var words = [String]()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [ESTWordProtocal]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SideBar Menu Controll
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let rowToselect: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(rowToselect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        // 로딩 이미지를 노출시킨다.
        ActivityModalView.shared.showActivityIndicator(self.view)
        getWordListJson("https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/words.json")
        
        // 테이블 뷰 설정
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredWords = wordSempleList.filter({ word in
            return word.word.lowercaseString.containsString(searchText.lowercaseString)
        })
        self.WordsTableView.reloadData()
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
                        self.WordDataBySwiftyJSON = JSON(data: data)
                        //print(self.WordDataBySwiftyJSON)
                        
                        // Json 데이터가 담겨있다면
                        if self.WordDataBySwiftyJSON.count > 0 {
                            
                            // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                            self.allWordData = self.alphabetizeArray(self.WordDataBySwiftyJSON)
                            //print(self.allWordData)
                            
                            self.WordsTableView.reloadData()
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    
    func alphabetizeArray(JsonData: JSON) -> [String: [ESTWordProtocal]] {
        var result = [String: [ESTWordProtocal]]()

        // 단어를 ESTWordProTocal 타입으로 담아놓는다.
        for item in JsonData["voca"] {
            if let word: ESTWordProtocal = ESTWordStruct(word: (item.1["word"].stringValue), means_ko: (item.1["means_ko"].stringValue), means_en: (item.1["means_en"].stringValue), date: (item.1["date"].stringValue)) {
                
                wordSempleList.append(word)
            }
        }
        
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
    func getSortedKeys(sections: [String: [ESTWordProtocal]]) -> [String] {
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
            let keys = self.allWordData.keys
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
            let sortedKeys = getSortedKeys(allWordData)
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
            let sortedKeys = getSortedKeys(allWordData)
            let key = sortedKeys[section]
            
            if let words = allWordData[key] {
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
            let keys = getSortedKeys(allWordData)
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
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let keys = allWordData.keys.sort({ (a, b) -> Bool in
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
        let keys = allWordData.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegueWithIdentifier("goWordMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = allWordData[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegueWithIdentifier("goWordMeaningView", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selectedWord: ESTWordProtocal!
        
        let keys = allWordData.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        if (segue.identifier == "goWordMeaningView") {
            
            // 
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.active && searchController.searchBar.text != "" {
                    selectedWord = filteredWords[indexPath.row]
                    
                } else {
                    let key = keys[indexPath.section]
                    if let words = allWordData[key] {
                        selectedWord = words[indexPath.row]
                    }
                }
            }
            
            let controller = segue.destinationViewController as? WordMeamingViewController
            controller!.selectedWord = selectedWord
        }
    }
    
}

extension WordsTableController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
