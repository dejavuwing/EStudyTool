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

    //var selectedChannelIndex: Int!
    
    
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
        
        webSiteTable.delegate = self
        webSiteTable.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Section의 수를 확인한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Section의 cell 수를 반환한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ESTGlobal.webSiteDataArray.count
    }
    
    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "myWebSiteList", for: indexPath as IndexPath)
        
        cell.textLabel?.text = ESTGlobal.webSiteDataArray[indexPath.row]["title"]
        cell.detailTextLabel?.text = ESTGlobal.webSiteDataArray[indexPath.row]["url"]

        // Cell을 보여주기 전에 로딩 이미지를 닫느다.
        ActivityModalView.shared.hideActivityIndicator()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goStudySiteView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedSiteUrl: String = ""
        
        if (segue.identifier == "goStudySiteView") {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                var selectedSite = ESTGlobal.webSiteDataArray[indexPath.row]
                print(selectedSite["url"])
                
                selectedSiteUrl = selectedSite["url"]!
            }
            
            let controller = segue.destination as? WebSiteViewController
            controller!.selectedSiteUrl = selectedSiteUrl
        }
    }
    
}
