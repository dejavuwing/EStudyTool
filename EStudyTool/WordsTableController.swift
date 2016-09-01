//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

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

class WordsTableController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet var jsonTableView: UITableView!
    
    var tableData = []
    var sections = [String: [jakesWord]]()
    var sectionCount: Int = 0
    var words = [String]()
    
    var wordList = [jakesWord]()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [jakesWord]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SideBar Menu Controll
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
//        let myNewItemKey = "a lot of"
//        let newWorld = "arbitrary"
//        
//        // plist에서 데이터를 읽어온다.
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![0])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![1])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![2])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![3])")
//        
//        
//        // plist에 존재하지 않는 key의 value를 불러올 경우 실행하지 않기
//        if (PlistManagerForWords.sharedInstance.getValueForKey(newWorld) != nil) {
//            
//            // 단어가 존재할 경우 수정한다.
//            //let newWorld = "arbitrary"
//            let list = ["임의의, 독단적인, 제멋대로의, 그런대로", "if you describe an action, rule, or decision as arbitrary, you think that it is not based on any principle, plan, or system. It often seems unfair because of this.", 0, "2016-08-30"]
//            PlistManagerForWords.sharedInstance.saveValue(list, forKey: newWorld)
//            
//            
//        } else {
//            // 단어가 없다면 추가한다.
//            let list = ["임의의, 독단적인, 제멋대로의", "if you describe an action, rule, or decision as arbitrary, you think that it is not based on any principle, plan, or system. It often seems unfair because of this.", 0, "2016-08-30"]
//            PlistManagerForWords.sharedInstance.addNewItemWithKey(newWorld , value: list)
//        }
//
//        
//        // plist에서 데이터를 읽어온다.
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![0])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![1])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![2])")
//        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![3])")
        
        
        
        let rowToselect: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(rowToselect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        // 로딩 이미지를 노출시킨다.
        ActivityModalView.shared.showActivityIndicator(self.view)
        getWordListJson("https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Assets/words.json")
        //getWordListJson("https://raw.githubusercontent.com/dejavuwing/swiftSample/master/swiftSample/swiftSample/swiftSample/Word-List-7.json")
        
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
        filteredWords = wordList.filter({ word in
            return word.word.lowercaseString.containsString(searchText.lowercaseString)
        })
        self.jsonTableView.reloadData()
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
                        let theJSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary
                        
                        if theJSON.count > 0 {
                            let results: NSArray = theJSON["voca"] as! NSArray
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.tableData = results
                                
                                // Alphabetize Word (데이터 정렬과 secion 분리를 위해 json 데이터를 넘긴다.)
                                self.sections = self.alphabetizeArray(theJSON)
                                
                                self.jsonTableView.reloadData()
                            })
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                }
            }
        }
        networkTask.resume()
    }
    
    func alphabetizeArray(JsonData: NSMutableDictionary) -> [String: [jakesWord]] {
        var result = [String: [jakesWord]]()
        
        // Json 데이터에서 word를 [String] 으로 뺀다.
        if let voca = JsonData["voca"] as? [[String: AnyObject]] {
            
            for word in voca {
                if let word: jakesWord = wordEl(word: (word["word"] as? String)!, means_ko: (word["means_ko"] as? String)!, means_en: (word["means_en"] as? String)!) {
                    // print("\(wordList.word) : \(wordList.means_ko) : \(wordList.means_en)")
                    wordList.append(word)
                    
                }
            }
        }
        
        for item in wordList {
            let index = item.word.startIndex.advancedBy(1)
            let firstLetter = item.word.substringToIndex(index).uppercaseString
            
            if result[firstLetter] != nil {
                result[firstLetter]!.append(item)
            } else {
                result[firstLetter] = [item]
            }
        }
        
        for (key, value) in result {
            result[key] = value.sort({ (a, b) -> Bool in
                a.word.lowercaseString < b.word.lowercaseString
            })
        }
        
        return result
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [jakesWord]]) -> [String] {
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
            let keys = sections.keys
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
            let sortedKeys = getSortedKeys(sections)
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
            let sortedKeys = getSortedKeys(sections)
            let key = sortedKeys[section]
            if let words = sections[key] {
                print("section count : \(words.count)")
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
            let keys = getSortedKeys(sections)
            let key = keys[indexPath.section]
            if let words = sections[key] {
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
        let keys = sections.keys.sort({ (a, b) -> Bool in
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
            print("\(title) : \(index)")
            return index
        }
    }
    
    // Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let keys = sections.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.active && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegueWithIdentifier("goMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = sections[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegueWithIdentifier("goMeaningView", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selectedWord: jakesWord!
        let keys = sections.keys.sort({ (a, b) -> Bool in
            a.lowercaseString < b.lowercaseString
        })
        
        if (segue.identifier == "goMeaningView") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.active && searchController.searchBar.text != "" {
                    selectedWord = filteredWords[indexPath.row]
                } else {
                    let key = keys[indexPath.section]
                    if let words = sections[key] {
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
