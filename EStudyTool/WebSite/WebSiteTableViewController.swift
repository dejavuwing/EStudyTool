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
    
    var channelsDataArray: [[String: String]] = []
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
            if let desiredChannelsArray = response as? [[String: String]] {
                print(desiredChannelsArray)
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // web site 리스트를 불러온다.
    func getSiteListJSON(callback: @escaping ([[String: String]]) -> ()) {
        var returnValue: [[String: String]] = []
        
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
                        
                        print(siteListJSON)
                        
//                        for item in siteListJSON["ESTWebs"] {
//                            
//                            print(item.1["title"].string)
//                            print(item.1["rul"].string)
//                            
//                            
////                            returnValue["title"]
////                            returnValue.append(item.1["title"]stringValue)
//                            
//                        }
                    }
                }
                
                callback(returnValue)
                //self.desiredChannelsArray = returnValue
            }
            
        }
        networkTask.resume()
    }
    
    
    


    
    
    // Section 수를 반환한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Section의 cell 수를 반환한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.channelsDataArray.count
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath as IndexPath)
        
        let channelTitleLabel = cell.viewWithTag(10) as! UILabel
        let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
        let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
        
        let channelDetails = channelsDataArray[indexPath.row]
        print(channelDetails["title"])
        
        channelTitleLabel.text = channelDetails["title"]
        channelDescriptionLabel.text = channelDetails["description"]
        thumbnailImageView.image = UIImage(data: NSData(contentsOf: NSURL(string: (channelDetails["thumbnail"])!)! as URL)! as Data)
        
        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            selectedChannelIndex = indexPath.row
            performSegue(withIdentifier: "goYoutubeView", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedChannel: String = ""
        
        if (segue.identifier == "goYoutubeView") {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let channelDetails = channelsDataArray[indexPath.row]
                print(channelDetails["id"])
                
                selectedChannel = channelDetails["id"]!
            }
            
            let controller = segue.destination as? youtubeWebController
            controller!.selectedChannel = selectedChannel
        }
    }
    
}
