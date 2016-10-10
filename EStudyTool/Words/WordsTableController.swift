//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON

class WordsTableController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var WordsTableView: UITableView!

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
        
        WordsTableView.delegate = self
        WordsTableView.dataSource = self
        
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
        filteredWords = ESTGlobal.wordSempleList.filter({ word in
            // 영어 단어와 한글 뜻에서 검색어를 찾아 반환한다.
            return word.word.lowercased().contains(searchText.lowercased()) || word.means_ko.lowercased().contains(searchText.lowercased())
        })
        
        self.WordsTableView.reloadData()
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
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
            
        } else {
            let keys = ESTGlobal.allWordData.keys
            self.sectionCount = keys.count
            
            return keys.count
        }
    }
    
    // Section의 순서와 String을 확인한다.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
            
        } else {
            let sortedKeys = getSortedKeys(sections: ESTGlobal.allWordData)
            return sortedKeys[section]
        }
    }
    
    // Section 단위의 테이블 수를 확인한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 검색한 단어 수 리턴하기
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredWords.count
            
        } else {
            let sortedKeys = getSortedKeys(sections: ESTGlobal.allWordData)
            let key = sortedKeys[section]

            if let words = ESTGlobal.allWordData[key] {
                return words.count
            }
        }
        
        return 0
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "myWordList")
        
        // 검색한 단어를 cell에 전달
        if searchController.isActive && searchController.searchBar.text != "" {
            let word = filteredWords[indexPath.row]
            cell.textLabel?.text = word.word
            
        } else {
            let keys = getSortedKeys(sections: ESTGlobal.allWordData)
            let key = keys[indexPath.section]
            
            if let words = ESTGlobal.allWordData[key] {
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
        let keys = ESTGlobal.allWordData.keys.sorted(by: { (a, b) -> Bool in
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
        let keys = ESTGlobal.allWordData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            print("did Select Row At IndexPath: \(filteredWords[indexPath.row])")
            performSegue(withIdentifier: "goWordMeaningView", sender: self)
            
        } else {
            let key = keys[indexPath.section]
            if let words = ESTGlobal.allWordData[key] {
                print("did Select Row At IndexPath: \(words[indexPath.row])")
                performSegue(withIdentifier: "goWordMeaningView", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedWord: ESTWordProtocal!
        
        let keys = ESTGlobal.allWordData.keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        if (segue.identifier == "goWordMeaningView") {
            
            //
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if searchController.isActive && searchController.searchBar.text != "" {
                    selectedWord = filteredWords[indexPath.row]
                    
                } else {
                    let key = keys[indexPath.section]
                    if let words = ESTGlobal.allWordData[key] {
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


