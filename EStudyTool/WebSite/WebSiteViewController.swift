//
//  youtubeWebController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 28..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit
import WebKit

class WebSiteViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var selectedSiteUrl: String!
    
    var webView = WKWebView()
    var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height))
        
        let myURL = URL(string: selectedSiteUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        view.addSubview(webView)

        progressBar = UIProgressView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: 50))
        progressBar.progress = 0.0
        progressBar.tintColor = UIColor.red
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(progressBar)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            
            print(Float(webView.estimatedProgress))
            
            progressBar.alpha = 1.0
            progressBar.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, //Time duration you want,
                    delay: 0.1,
                    options: [.curveEaseInOut],
                    animations: { () -> Void in
                        self.progressBar.alpha = 0.0},
                    completion: { (finished:Bool) -> Void in
                        self.progressBar.progress = 0})
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
