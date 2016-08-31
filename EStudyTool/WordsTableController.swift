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
        
        // SideBar Menu Controll
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        let myNewItemKey = "a lot of"
        let newWorld = "arbitrary"
        
        
        
        // plist에서 데이터를 읽어온다.
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![0])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![1])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![2])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(myNewItemKey)![3])")
        
        
        // plist에 존재하지 않는 key의 value를 불러올 경우 실행하지 않기
        if (PlistManagerForWords.sharedInstance.getValueForKey(newWorld) != nil) {
            
            // 단어가 존재할 경우 수정한다.
            //let newWorld = "arbitrary"
            let list = ["임의의, 독단적인, 제멋대로의, 그런대로", "if you describe an action, rule, or decision as arbitrary, you think that it is not based on any principle, plan, or system. It often seems unfair because of this.", 0, "2016-08-30"]
            PlistManagerForWords.sharedInstance.saveValue(list, forKey: newWorld)
            
            
        } else {
            // 단어가 없다면 추가한다.
            let list = ["임의의, 독단적인, 제멋대로의", "if you describe an action, rule, or decision as arbitrary, you think that it is not based on any principle, plan, or system. It often seems unfair because of this.", 0, "2016-08-30"]
            PlistManagerForWords.sharedInstance.addNewItemWithKey(newWorld , value: list)
        }

        
        // plist에서 데이터를 읽어온다.
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![0])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![1])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![2])")
        print("\(PlistManagerForWords.sharedInstance.getValueForKey(newWorld)![3])")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
