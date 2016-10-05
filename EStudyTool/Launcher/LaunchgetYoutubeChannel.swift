//
//  LaunchgetYoutubeChannel.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 5..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

class LaunchgetYoutubeChannel {
    
    let apiKey: String = "AIzaSyB7axvVjh9cQtbuqpbdBcMibbCcKDPwvPA"
    var channelIndex = 0
    var channelsDataArray: [[String: String]] = []
    
    
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
            }
        }
        networkTask.resume()
        ESTGlobal.finishLoadYoutubeChannels = true
    }
    
    
    // Youtube 체널 정보를 가져온다.
    func getChannelDetails(channells: [String]) {
        var urlString: String!
        let mySession = URLSession.shared
        
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
                            ESTGlobal.channelsDataArray.append(desiredValuesDict as [String : String])
                            
                            print("channel : \(item.1["snippet"]["title"].stringValue)")
                        }
                        
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
    
    
}
