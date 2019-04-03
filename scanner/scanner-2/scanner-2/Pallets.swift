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
    
    if output == "AR" {
        for palletIndex in 0..<set.pallets.count {
            for boxIndex in 0..<set.pallets[palletIndex].items.count {
                let box = set.pallets[palletIndex].items[boxIndex]
                set.pallets[palletIndex].items[boxIndex].width = box.length
                set.pallets[palletIndex].items[boxIndex].height = box.width
                set.pallets[palletIndex].items[boxIndex].length = box.height

                
                // using unchanged constant box dimensions
                set.pallets[palletIndex].items[boxIndex].position[0] = box.position[0] + box.length/2 - Constants.palletLength/2
                set.pallets[palletIndex].items[boxIndex].position[1] = box.position[1]*(-1) - box.width/2 + Constants.palletWidth/2
                set.pallets[palletIndex].items[boxIndex].position[2] = box.position[2] + box.height/2
            }
        }
    }
        
    else if output == "3D" {
        for palletIndex in 0..<set.pallets.count {
            let m_per_inch = Float(0.0254)
            for boxIndex in 0..<set.pallets[palletIndex].items.count {
                let box = set.pallets[palletIndex].items[boxIndex]
                set.pallets[palletIndex].items[boxIndex].width = box.length / m_per_inch
                set.pallets[palletIndex].items[boxIndex].height = box.height / m_per_inch
                set.pallets[palletIndex].items[boxIndex].length = box.width / m_per_inch
            
                set.pallets[palletIndex].items[boxIndex].position[0] = box.position[0] / m_per_inch
                set.pallets[palletIndex].items[boxIndex].position[1] = box.position[2] / m_per_inch
                set.pallets[palletIndex].items[boxIndex].position[2] = (box.position[1]) / m_per_inch
            }
        }
    }
    
    /* Reorder boxes in increasing box number order */
    for palletIndex in 0..<set.pallets.count {
        set.pallets[palletIndex].items = set.pallets[palletIndex].items.sorted(by: { $0.id < $1.id })
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
