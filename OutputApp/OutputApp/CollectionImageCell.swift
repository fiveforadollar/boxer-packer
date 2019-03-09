//
//  CollectionImageCell.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-02-02.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import UIKit

class CollectionImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool{
        willSet{
            if newValue
            {
                let photo = UIImage(named: "pallet-icon-blue.png")
                
                self.imageView.image = photo
            }
            else
            {
                let photo = UIImage(named: "pallet-icon.png")
                
                self.imageView.image = photo
            }
        }
    }
}
