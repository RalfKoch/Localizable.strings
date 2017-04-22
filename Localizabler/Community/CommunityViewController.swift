//
//  CommunityViewController.swift
//  Localizable.strings
//
//  Created by Cristian Baluta on 21/04/2017.
//  Copyright © 2017 Cristian Baluta. All rights reserved.
//

import Cocoa

class CommunityViewController: NSViewController {
    
    var presenter: CommunityPresenterInput?
    
    class func instanceFromStoryboard() -> CommunityViewController {
        let storyBoard = NSStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateController(withIdentifier: "CommunityViewController") as! CommunityViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension CommunityViewController: CommunityPresenterOutput {
    
}