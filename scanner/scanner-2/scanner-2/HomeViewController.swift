//
//  HomeViewController.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-03-24.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var viewLayoutButton: UIButton!
    @IBOutlet weak var logoView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BaseColors.yellow
        self.newSessionButton.setTitleColor(BaseColors.grey, for: .normal)
        self.viewLayoutButton.setTitleColor(BaseColors.grey, for: .normal)
        //logoView.layer.cornerRadius = 20
        logoView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
