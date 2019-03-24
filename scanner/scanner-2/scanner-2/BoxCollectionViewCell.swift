//
//  BoxCollectionViewCell.swift
//  scanner-2
//
//  Created by Kathy Huang on 2019-03-20.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import UIKit

class BoxCollectionViewCell: UICollectionViewCell {
    
    // For AR pallet selection bar
    
    // For 3d representation's pallet selection bar
    @IBOutlet weak var boxImageView: UIImageView!
    
    override var isSelected: Bool{
        willSet{
            if newValue
            {
                let photo = UIImage(named: "box-blue.png")

                self.boxImageView.image = photo


            }
            else
            {
                let photo = UIImage(named: "box.png")

                self.boxImageView.image = photo

            }
        }
    }
}
