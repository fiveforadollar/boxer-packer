//
//  SetTableViewController.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-03-18.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct set {
    var setName : String!
    var setID : Int!
    var date : String!
    var boxCount : Int!
}

class SetTableViewController: UITableViewController {

    var sets = [set]()
    var selectedSet : Int!
    var setData: String!
    
    func getSetOrientationData() {
        let parameters = [
            "setID" : self.selectedSet,
        ]

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Alamofire.request(Constants.baseURL + "getset", method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
//                    let json = JSON.init(parseJSON: utf8Text)
                    //let test = json["datetime"].stringValue
                    self.setData = utf8Text
                    
                    self.performSegue(withIdentifier: "setSegue", sender: self)
                    //let alert = UIAlertController(title: test, message: test, preferredStyle: .alert)

                    //alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

                    //self.present(alert, animated: true)

                }
            }
    }
    
    func getData() {
        Alamofire.request(Constants.baseURL + "sets", method: .get)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let setNames = json.arrayValue
                    for set_ in setNames {
                        let setName = "Set " + set_["setID"].stringValue
                        let date = set_["datetime"].stringValue
                        let boxCount = set_["numBoxes"].intValue
                        let newSet = set(setName: setName, setID: set_["setID"].intValue, date: date, boxCount: boxCount)
                        self.sets.append(newSet)
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setTableViewCell", for: indexPath) as! SetTableViewCell
        cell.setNameLabel.text = sets[indexPath.row].setName
        cell.setDateLabel.text = sets[indexPath.row].date
        cell.boxCountLabel.text = "Box count: " + String(sets[indexPath.row].boxCount)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSet = sets[indexPath.row].setID
        getSetOrientationData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "setSegue" {
            let destination = segue.destination as? ChooseOutputViewController
//            destination?.setID = self.selectedSet
            destination?.setData = self.setData
        }
    }
 

}
