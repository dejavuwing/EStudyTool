//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON

class DialoguesTableController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var DialoguesTableView: UITableView!

    var sectionCount: Int = 0
    
    // DB 경로
    var databasePath = NSString()
    
    // 테이블 검색을 위해
    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [ESTDialogueProtocal]()
    
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
        
        DialoguesTableView.delegate = self
        DialoguesTableView.dataSource = self
        
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
        filteredWords = ESTGlobal.dialougeSempleList.filter({ dialogue in
            // 영어 패턴과 한글 뜻에서 검색어를 찾아 반환한다.
            return dialogue.dialogueTitle.lowercased().contains(searchText.lowercased()) || dialogue.dialogue_en.lowercased().contains(searchText.lowercased())
        })
        
        self.DialoguesTableView.reloadData()
    }
    
    // key를 정렬해 반환한다.
    func getSortedKeys(sections: [String: [ESTPatternProtocal]]) -> [String] {
        let keys = sections.keys
        
        let sortedKeys = keys.sorted(by: { (a, b) -> Bool in
            a.lowercased() < b.lowercased()
        })
        
        return sortedKeys
    }
    
    // 검색 아이콘을 누르면 search Bar가 나온다.
    @IBAction func searchPocus(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    
    
    // Section의 수를 확인한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "myDialogueList")
        
        // 검색한 패턴을 cell에 전달
        if searchController.isActive && searchController.searchBar.text != "" {
            let dailogue = filteredWords[indexPath.row]
            cell.textLabel?.text = dailogue.dialogueTitle
            
        } else {
            cell.textLabel?.text = ESTGlobal.dialougeSempleList[indexPath.row].dialogueTitle
            
        }
        
        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    // Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goDialogueMeaningView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedDialogue: ESTDialogueProtocal!
        if (segue.identifier == "goDialogueMeaningView") {

            if let indexPath = self.tableView.indexPathForSelectedRow {
                if searchController.isActive && searchController.searchBar.text != "" {
                    selectedDialogue = filteredWords[indexPath.row]
                    
                } else {
                   selectedDialogue = ESTGlobal.dialougeSempleList[indexPath.row]
                }
            }
            
            let controller = segue.destination as? DialoguesMeamingViewController
            controller!.selectedDialogue = selectedDialogue
        }
    }
}

extension DialoguesTableController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



