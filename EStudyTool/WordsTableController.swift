//
//  WordsTableController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 8. 30..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class WordsTableController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if revealViewController() != nil {
            // revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
