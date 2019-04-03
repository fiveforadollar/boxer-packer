//
//  CollectionImageCell.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-02-02.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import UIKit

class CollectionImageCell: UICollectionViewCell {
    
    // For AR pallet selection bar
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var palletNumber: UILabel!
    // For 3d representation's pallet selection bar

    override var isSelected: Bool{
        willSet{
            if newValue
            {
                let photo = UIImage(named: "pallet.png")
                self.backgroundColor = UIColor.flatYellow
                self.imageView.image = photo
           
                
            }
            else
            {
                let photo = UIImage(named: "pallet.png")
                self.backgroundColor = UIColor.clear
                self.imageView.image = photo
               
            }
        }
    }
}
