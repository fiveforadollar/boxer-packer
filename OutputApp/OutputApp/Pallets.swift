//
//  Pallets.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-02-02.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import Foundation

struct Box: Codable {
    let id: Int
    let length: Float
    let width: Float
    let height: Float
    let position: [Float]
}

struct Pallet: Codable {
    let id: Int
    let items: [Box]
}


// TODO:
// 1 Parse output of algorithm for box locations and orientations
// 2 Choose which pallet to display
// 3 Display on any flat surface, set the center of the surface to center of bottom of pallet
//  (sizes may be different; can use hittest select plane)
// 4 Calculate position of front left corner of pallet in ARSCNView
// 5 For each box for that pallet, calculate its position in ARSCNView given relative location
