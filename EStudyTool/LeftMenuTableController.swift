//
//  LeftMenuTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class LeftMenuTableController: UITableViewController {
    
    var ToolSection: [String] = ["Voca", "Youtube"]
    var ToolList: [[String]] = [["Words", "Pattern"], ["engVid"]]
    var ToolDesc: [[String]] = [["기본 단어 검색", "말하기 패턴"], ["http://www.engvid.com"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let rowToselect: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(rowToselect, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Section의 수를 확인한다.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ToolSection.count
    }
    
    // Section의 순서와 String을 확인한다.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ToolSection[section]
    }
    
    // Section 단위의 테이블 수를 확인한다.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ToolList[section].count
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // cell의 style과 이름을 정의한다.
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "ToolList")
        
        let section = indexPath.section
        
        // objectList와 objectDesc에서 indexPath.row에 해당하는 값을 가져온다.
        cell.textLabel?.text = self.ToolList[section][indexPath.row]
        cell.detailTextLabel?.text = self.ToolDesc[section][indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // 클릭된 테이블 열 번호에 따라 페이지를 이동시킨다.

    }
}

