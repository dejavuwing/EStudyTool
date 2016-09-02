//
//  WordMeamingViewController.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 1..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import UIKit


class WordMeamingViewController: UIViewController {
    
    var selectedWord: ESTWordProtocal!
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meanTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //wordLabel.text = selectedWord.word
        //meanTextView.text = selectedWord.means_en.stringByReplacingOccurrencesOfString("\\n", withString: "\r\r")
        print("----------------------> \(selectedWord)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
