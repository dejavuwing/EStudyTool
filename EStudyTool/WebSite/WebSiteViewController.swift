//
//  youtubeWebController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 28..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class WebSiteViewController: UIViewController {
    
    @IBOutlet weak var mySiteView: UIWebView!
    
    var selectedSiteUrl: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedSiteUrl)
        
        mySiteView.loadRequest(URLRequest(url: URL(string: selectedSiteUrl)!))
        
        self.view.addSubview(mySiteView)
        addPullToRefreshToWebView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 땡겨서 refresh
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.bounds = CGRect(x: 0, y: 50, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(WebSiteViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        mySiteView.scrollView.addSubview(refreshController)
        
    }
    
    func refreshWebView(_ refresh:UIRefreshControl){
        mySiteView.reload()
        refresh.endRefreshing()
    }
}
