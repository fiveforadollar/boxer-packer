//
//  Pallets.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-02-02.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import Foundation

struct Box: Codable {
    var id: Int
    var length: Float
    var width: Float
    var height: Float
    var position: [Float]
}

struct Pallet: Codable {
    var id: Int
    var items: [Box]
}

struct Set: Codable {
    var pallets: [Pallet]
    var datetime: Date
    var setID: Int
    
    init() {
        pallets = []
        datetime = Date()
        setID = 0
    }
}


func parseJSON(_ json: Data, _ set: Set, output: String) -> Set {
    let decoder = JSONDecoder()
    var set = set
    decoder.dateDecodingStrategy = .iso8601
    do {
        set = try decoder.decode(Set.self, from: json)
    }
    catch {
        print("caught: \(error)")
    }
    
    if output == "AR"{
        var temp: Float
        for var pallet in set.pallets{
            for var box in pallet.items{
                temp = box.width
                box.width = box.height / 1000
                box.height = temp / 1000
                box.length = box.length / 1000
                
                box.position[0] = box.position[0]/1000 + Constants.palletWidth - box.width/2
                temp = box.position[1]
                box.position[1] = box.position[2] / 1000 + box.height/2
                box.position[2] = temp / 1000 + Constants.palletLength - box.length/2
                
            }
        }
    }
        
    else if output == "3D" {
        for palletIndex in 0..<set.pallets.count {
            let mm_per_inch = Float(25.4)
            for boxIndex in 0..<set.pallets[palletIndex].items.count {
                let box = set.pallets[palletIndex].items[boxIndex]
                set.pallets[palletIndex].items[boxIndex].width = box.width / mm_per_inch
                set.pallets[palletIndex].items[boxIndex].height = box.height / mm_per_inch
                set.pallets[palletIndex].items[boxIndex].length = box.length / mm_per_inch
            
                set.pallets[palletIndex].items[boxIndex].position[0] = box.position[0] / mm_per_inch
                set.pallets[palletIndex].items[boxIndex].position[1] = box.position[1] / mm_per_inch
                set.pallets[palletIndex].items[boxIndex].position[2] = box.position[2] / mm_per_inch
            }
        }
    }
    return set
}

// TODO:
// 1 Parse output of algorithm for box locations and orientations
// 2 Choose which pallet to display
// 3 Display on any flat surface, set the center of the surface to center of bottom of pallet
//  (sizes may be different; can use hittest select plane)
// 4 Calculate position of front left corner of pallet in ARSCNView
// 5 For each box for that pallet, calculate its position in ARSCNView given relative location
