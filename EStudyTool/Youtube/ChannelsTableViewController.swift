//
//  ChannelsTableViewController.swift
//  swiftSample
//
//  Created by ngle on 2016. 8. 17..
//  Copyright © 2016년 ngle. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //@IBOutlet weak var tblVideos: UITableView!
    
    //@IBOutlet weak var segDisplayedContent: UISegmentedControl!
    
    //@IBOutlet weak var txtSearch: UITextField!
    
    var apiKey = "AIzaSyB7axvVjh9cQtbuqpbdBcMibbCcKDPwvPA"
    
    var desiredChannelsArray = ["Apple", "Google", "EnglishLessons4U", "Microsoft"]
    var channelIndex = 0
    
    var channelsDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var selectedVideoIndex: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //tblVideos.delegate = self
        //tblVideos.dataSource = self
        
        getChannelDetails()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "idSeguePlayer" {
//            let playerViewController = segue.destinationViewController as! PlayerViewController
//            playerViewController.videoID = videosArray[selectedVideoIndex]["videoID"] as! String
//        }
//    }
    

    // Youtube 체널 정보를 가져온다.
    func getChannelDetails() {
        
        
        
        var urlString: String!
        let mySession = URLSession.shared
        
        urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        
        let url: NSURL = NSURL(string: urlString)!
        let networkTask = mySession.dataTask(with: url as URL) { (channelData, response, error) -> Void in
            if error != nil {
                print("[getChannelDetails] fetch Failed : \(error?.localizedDescription)")
                
            } else {
                if let data = channelData {
                    do {
                        let channelJSON = JSON(data: data)
                        
                        for item in channelJSON["items"] {
                            
                            // Create a new dictionary to store only the values we care about.
                            var desiredValuesDict: Dictionary<String, String> = Dictionary<String, String>()
                            desiredValuesDict["title"] = item.1["snippet"]["title"].stringValue
                            desiredValuesDict["description"] = item.1["snippet"]["description"].stringValue
                            desiredValuesDict["thumbnail"] = item.1["snippet"]["thumbnails"]["default"]["url"].stringValue
                            
                            
                            
                            // Append the desiredValuesDict dictionary to the following array.
                            self.channelsDataArray.append(desiredValuesDict as [NSObject : AnyObject])

                            
                        }
                        
                        // Load the next channel data (if exist).
                        self.channelIndex += 1
                        if self.channelIndex < self.desiredChannelsArray.count {
                            self.getChannelDetails()
                        }
                        else {
                            
                            //ActivityModalView.shared.hideActivityIndicator()
                        }
                        
                        print(self.channelsDataArray)

                        
                    }
                } else {
                    print("Error~~~")
                }
            }
        }
        networkTask.resume()

       
        
        
        

    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    // Section 수를 반환한다.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Section의 cell 수를 반환한다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return channelsDataArray.count
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath as IndexPath)
        
        let channelTitleLabel = cell.viewWithTag(10) as! UILabel
        let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
        let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
        
        let channelDetails = channelsDataArray[indexPath.row]
        channelTitleLabel.text = channelDetails["title"] as? String
        channelDescriptionLabel.text = channelDetails["description"] as? String
        thumbnailImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (channelDetails["thumbnail"] as? String)!)!)!)
        
        
        return cell
    }
    
    
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 100.0
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            // In this case the channels are the displayed content.
            // The videos of the selected channel should be fetched and displayed.
            
            // Switch the segmented control to "Videos".
            segDisplayedContent.selectedSegmentIndex = 1
            
            // Show the activity indicator.
            //viewWait.hidden = false
            ActivityModalView.shared.showActivityIndicator(view: self.view)
            
            // Remove all existing video details from the videosArray array.
            videosArray.removeAll(keepingCapacity: false)
            
            // Fetch the video details for the tapped channel.
            getVideosForChannelAtIndex(index: indexPath.row)
        }
        else {
            selectedVideoIndex = indexPath.row
            performSegue(withIdentifier: "idSeguePlayer", sender: self)
        }
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //viewWait.hidden = false
        ActivityModalView.shared.showActivityIndicator(self.view)
        
        // Specify the search type (channel, video).
        var type = "channel"
        if segDisplayedContent.selectedSegmentIndex == 1 {
            type = "video"
            videosArray.removeAll(keepCapacity: false)
        }
        
        // Form the request URL string.
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(textField.text)&type=\(type)&key=\(apiKey)"
        print(urlString)
        
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Get the results.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary object.
                do {
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all search result items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Loop through all search results and keep just the necessary data.
                    for i in 0 ..< items.count {
                        let snippetDict = items[i]["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Gather the proper data depending on whether we're searching for channels or for videos.
                        if self.segDisplayedContent.selectedSegmentIndex == 0 {
                            // Keep the channel ID.
                            self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                        }
                        else {
                            // Create a new dictionary to store the video details.
                            var videoDetailsDict = Dictionary<NSObject, AnyObject>()
                            videoDetailsDict["title"] = snippetDict["title"]
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(videoDetailsDict)
                            
                            
                            
                            // Reload the tableview.
                            self.tblVideos.reloadData()
                        }
                    }
                } catch {
                    print(error)
                }
                
                // Call the getChannelDetails(…) function to fetch the channels.
                if self.segDisplayedContent.selectedSegmentIndex == 0 {
                    self.getChannelDetails(true)
                }
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(error)")
            }
            
            // Hide the activity indicator.
            //self.viewWait.hidden = true
            ActivityModalView.shared.hideActivityIndicator()
        })
        
        
        return true
    }

    
    
    
    
    
    func getVideosForChannelAtIndex(index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
        print(urlString)
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert the JSON data into a dictionary.
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(desiredPlaylistItemDataDict)
                        
                        print(self.videosArray)
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(error)")
            }
            
            // Hide the activity indicator.
            //self.viewWait.hidden = true
            ActivityModalView.shared.hideActivityIndicator()
        })
    }
 
 */

}
