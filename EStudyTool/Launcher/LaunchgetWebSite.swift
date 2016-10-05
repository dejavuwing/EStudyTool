//
//  LaunchgetWebSite.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 5..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

class LaunchgetWebSite {
    
    
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
                            
                            print("web site : \(item.1["title"].string!)")
                        }
                    }
                }
                callback(returnValue)
            }
        }
        networkTask.resume()
        ESTGlobal.finishLoadWebSites = true
    }
    
}
