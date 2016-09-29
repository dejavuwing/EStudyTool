//
//  ChannelsTableViewController.swift
//  swiftSample
//
//  Created by ngle on 2016. 8. 17..
//  Copyright © 2016년 ngle. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tblVideos: UITableView!
    
    let apiKey: String = "AIzaSyB7axvVjh9cQtbuqpbdBcMibbCcKDPwvPA"
    
    //var desiredChannelsArray: [String] = []
    var channelIndex = 0
    
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
        getChannelListJSON() {(response) in
            if let desiredChannelsArray = response as? [String] {
                print(desiredChannelsArray)
                self.getChannelDetails(channells: desiredChannelsArray)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // ChannelList를 불러온다. (closure의 return 방법 확인)
    func getChannelListJSON(callback: @escaping ([String]) -> ()) {
        var returnValue: [String] = []
        
        let mySession = URLSession.shared
        let versionUrl = "https://raw.githubusercontent.com/dejavuwing/EStudyTool/master/EStudyTool/Youtube/channelList.json"
        let url: NSURL = NSURL(string: versionUrl)!
        
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[getChannelListJSON] fetch Failed: \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        // Json 타입의 Array 정보를 가져온다.
                        let channelListJSON = JSON(data: data)
                        
                        for item in channelListJSON["youtube"]["channelList"] {
                            returnValue.append(item.1.stringValue)
                            
                        }
                    }
                }
                
                callback(returnValue)
                //self.desiredChannelsArray = returnValue
            }
            
        }
        networkTask.resume()
    }
    
    
    // Youtube 체널 정보를 가져온다.
    func getChannelDetails(channells: [String]) {
        
        var urlString: String!
        let mySession = URLSession.shared
        
        print("channel : \(channells)")
        
        urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(channells[channelIndex])&key=\(apiKey)"
        let url: NSURL = NSURL(string: urlString)!
        
        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[getChannelDetails] fetch Failed : \(error?.localizedDescription)")
                
            } else {
                if let data = data {
                    do {
                        let channelJSON = JSON(data: data)
                        
                        for item in channelJSON["items"] {
                            
                            // Create a new dictionary to store only the values we care about.
                            var desiredValuesDict: Dictionary<String, String> = Dictionary<String, String>()
                            desiredValuesDict["title"] = item.1["snippet"]["title"].stringValue
                            desiredValuesDict["description"] = item.1["snippet"]["description"].stringValue
                            desiredValuesDict["thumbnail"] = item.1["snippet"]["thumbnails"]["default"]["url"].stringValue
                            desiredValuesDict["id"] = item.1["id"].stringValue
                            
                            // Append the desiredValuesDict dictionary to the following array.
                            self.channelsDataArray.append(desiredValuesDict as [String : String])
                        }
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                        
                        // Load the next channel data (if exist).
                        self.channelIndex += 1
                        if self.channelIndex < channells.count {
                            self.getChannelDetails(channells: channells)
                        }
                    }
                }
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
