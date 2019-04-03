//
//  HomeViewController.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-03-24.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var viewLayoutButton: UIButton!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var jsonPicker: UIPickerView!
    
    var pickerData: [String] = [String]()
    var selectedData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BaseColors.yellow
        self.newSessionButton.setTitleColor(BaseColors.grey, for: .normal)
        self.viewLayoutButton.setTitleColor(BaseColors.grey, for: .normal)
        //logoView.layer.cornerRadius = 20
        logoView.clipsToBounds = true
        pickerData = ["set0", "stacked_setdone"]
        self.jsonPicker.delegate = self
        self.jsonPicker.dataSource = self
        jsonPicker.selectRow(0, inComponent: 0, animated: true)
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        selectedData = pickerData[row]
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
        if segue.identifier == "chooseJSON" {
            let destination = segue.destination as? ChooseOutputViewController
            if let path = Bundle.main.path(forResource: selectedData, ofType: "json")
            {
                do {
                    let fileUrl = URL(fileURLWithPath: path)
                    let data = try String(contentsOf: fileUrl, encoding: .utf8)
                    destination?.setData = data
                }
                catch {
    
                }
            }
        }
    }
}
