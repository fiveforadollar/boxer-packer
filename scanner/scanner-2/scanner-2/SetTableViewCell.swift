//
//  SetTableViewCell.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-03-18.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var setDateLabel: UILabel!
    @IBOutlet weak var boxCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
