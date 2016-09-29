//
//  youtubeWebController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 28..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class youtubeWebController: UIViewController {
    
    @IBOutlet weak var myWebView: UIWebView!
    
    // 할당하고 초기화
    //var myWebView: UIWebView = UIWebView()
    
    var selectedChannel: String!
    var viewUrl: String = "https://www.youtube.com/channel/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewUrl += selectedChannel
        myWebView.loadRequest(URLRequest(url: URL(string: viewUrl)!))
        
        self.view.addSubview(myWebView)
        addPullToRefreshToWebView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 땡겨서 refresh
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.bounds = CGRect(x: 0, y: 50, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(youtubeWebController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        myWebView.scrollView.addSubview(refreshController)
        
    }
    
    func refreshWebView(_ refresh:UIRefreshControl){
        myWebView.reload()
        refresh.endRefreshing()
    }

    
    
    
    
    
    
    
    
    
}
