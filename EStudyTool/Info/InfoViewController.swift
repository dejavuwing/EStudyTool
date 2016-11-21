//
//  InfoViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 10. 7..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit

class InfoViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var wordVersion: UILabel!
    @IBOutlet weak var wordAmount: UILabel!
    
    @IBOutlet weak var patternVersion: UILabel!
    @IBOutlet weak var patternAmount: UILabel!
    
    @IBOutlet weak var dialogueVersion: UILabel!
    @IBOutlet weak var dialogueAmount: UILabel!
    
    @IBOutlet weak var paragraphVersion: UILabel!
    @IBOutlet weak var paragraphAmount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사이드바 메뉴 설정
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let SavedWordVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version words")?.stringValue
        wordVersion?.text = SavedWordVersion
        
        let wordTotalCount = ESTFunctions().getItemCount(searchTable: "WORDS")
        wordAmount.text = String(wordTotalCount)
        
        let SavedPatternVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version patterns")?.stringValue
        patternVersion?.text = SavedPatternVersion
        
        let patternTotalCount = ESTFunctions().getItemCount(searchTable: "PATTERNS")
        patternAmount.text = String(patternTotalCount)
        
        let SavedDialougeVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version dialogues")?.stringValue
        dialogueVersion?.text = SavedDialougeVersion
        
        let dialogueTotalCount = ESTFunctions().getItemCount(searchTable: "DIALOUGES")
        dialogueAmount.text = String(dialogueTotalCount)
        
        let SavedParagraphVersion = PlistManager.sharedInstance.getValueForKey(key: "EST version paragraphes")?.stringValue
        paragraphVersion?.text = SavedParagraphVersion
        
        let paragraphTotalCount = ESTFunctions().getItemCount(searchTable: "PARAGRAPHES")
        paragraphAmount.text = String(paragraphTotalCount)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
