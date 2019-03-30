//
//  ChooseOutputViewController.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-03-18.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChooseOutputViewController: UIViewController {

    var setID : Int!
    
    var setData : String!
    
    func getSetData() {
        let parameters = [
            "setID" : self.setID,
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constants.baseURL + "getset", method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let test = json["datetime"].stringValue
                    self.setData = utf8Text
                    let alert = UIAlertController(title: test, message: test, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                    
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSetData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to3D" {
            let destination = segue.destination as? LayoutViewController
            //destination?.setData = self.setData
        }
        else if segue.identifier == "toAR" {
            let destination = segue.destination as? AROutputViewController
            destination?.setData = self.setData
        }
    }
    

}
