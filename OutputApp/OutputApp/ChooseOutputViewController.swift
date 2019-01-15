//
//  ViewController.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-01-14.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import UIKit

class ChooseOutputViewController: UIViewController {

    // MARK - Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func ChooseToARButon(_ sender: Any) {
        performSegue(withIdentifier: "ChooseToAR", sender: self)
    }
    
}

