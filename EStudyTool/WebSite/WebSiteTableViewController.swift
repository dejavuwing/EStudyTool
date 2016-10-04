//
//  ChannelsTableViewController.swift
//  swiftSample
//
//  Created by ngle on 2016. 8. 17..
//  Copyright © 2016년 ngle. All rights reserved.
//

import UIKit
import SwiftyJSON

class WebSiteTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var webSiteTable: UITableView!

    //var channelIndex = 0
    
    var sitesDataArray: [[String: String]] = []
    var selectedChannelIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // 로딩 이미지를 노출시킨다.
        ActivityModalView.shared.showActivityIndicator(view: self.view)
        
        // ChannelList를 불러온다. (closure의 return 방법 확인)
        getSiteListJSON() {(response) in
            if let desiredSitesArray: [[String: String]] = response {
                self.sitesDataArray = desiredSitesArray
                
                // Reload the tableview.
                self.webSiteTable.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // web site 리스트를 불러온다.
    func getSiteListJSON(callback: @escaping ([[String: String]]) -> ()) {
        var returnValue: [[String: String]] = []
        var siteInfo: [String: String] = [:]
        
        let mySession = URLSession.shared
        let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/WebSite/webSiteList.json"
        let url: NSURL = NSURL(string: versionUrl)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[getSiteListJSON] fetch Failed: \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        // Json 타입의 Array 정보를 가져온다.
                        let siteListJSON = JSON(data: data)
                        
                        for item in siteListJSON["ESTWebs"] {
                            
                            siteInfo = ["title": item.1["title"].string!, "url": item.1["url"].string!]
                            returnValue.append(siteInfo)
                        }
                    }
                }
                callback(returnValue)
            }
        }
        networkTask.resume()
    }
    
    // Section의 수를 확인한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Section의 cell 수를 반환한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sitesDataArray.count
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "myWebSiteList", for: indexPath as IndexPath)
        
        cell.textLabel?.text = self.sitesDataArray[indexPath.row]["title"]
        cell.detailTextLabel?.text = self.sitesDataArray[indexPath.row]["url"]

        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChannelIndex = indexPath.row
        performSegue(withIdentifier: "goStudySiteView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedSiteUrl: String = ""
        
        if (segue.identifier == "goStudySiteView") {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                var selectedSite = sitesDataArray[indexPath.row]
                print(selectedSite["url"])
                
                selectedSiteUrl = selectedSite["url"]!
            }
            
            let controller = segue.destination as? WebSiteViewController
            controller!.selectedSiteUrl = selectedSiteUrl
        }
    }
    
}
