//
//  LayoutViewController.swift
//  Visualization
//
//  Created by James Jin on 2019-03-09.
//  Copyright © 2019 boxer-packer. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class LayoutViewController: UIViewController {

    // Scene view that holds the layout scene
    @IBOutlet weak var scnView: SCNView!
    
    // Pallets data structure to be filled by incoming data
    var pallets = [Pallet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create scene
        let scene = SCNScene(named:"Layout.scnassets/Scenes/LayoutScene.scn")!
    
        // Set the scene to the view
        scnView.scene = scene
        
        // Allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // Show statistics such as fps and timing information
        scnView.showsStatistics = true
  
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // Get pallet/box data to be visualized
        let json = """
        [
            {
                "id": 0,
                "items": [
                    {
                        "height": 1.0,
                        "id": 3,
                        "length": 1.0,
                        "position": [
                            0.0,
                            0.0,
                            0.0
                        ],
                        "width": 1.0
                    },
                    {
                        "height": 51.0,
                        "id": 2,
                        "length": 39.0,
                        "position": [
                            1.0,
                            0.0,
                            0.0
                        ],
                        "width": 47.0
                    }
                ],
                "numBoxes": 2
            },
            {
                "id": 1,
                "items": [
                    {
                        "height": 51.0,
                        "id": 1,
                        "length": 39.0,
                        "position": [
                            0.0,
                            0.0,
                            0.0
                        ],
                        "width": 47.0
                    }
                ],
                "numBoxes": 1
            }
        ]
        """.data(using: .utf8)!
        parseJSON(json)
        
        // Draw each box in their corresponding pallets
        // TODO: currently only does pallet 1
        for box in (pallets[0].items) {
            let cubeGeometry = SCNBox(width: CGFloat(box.width), height: CGFloat(box.height), length: CGFloat(box.length), chamferRadius: 0.0)
            // Create the cube's pivot point to be its back left corner
            let cubePivot = SCNMatrix4MakeTranslation(-(box.width/2), -(box.height/2), (box.length/2))
            let cubePosition = SCNVector3 (
                x: box.position[0],
                y: box.position[1],
                z: box.position[2]
            )

            // Set the cube's dimensions, pivot and position through its node
            let cubeNode = SCNNode(geometry: cubeGeometry)
            cubeNode.position = cubePosition
            cubeNode.pivot = cubePivot
            scene.rootNode.addChildNode(cubeNode)
        }
    }
    
    // Decode/parse the incoming pallet data and store into the pallets data structure
    func parseJSON(_ json: Data){
        let decoder = JSONDecoder()
        do {
            pallets = try decoder.decode([Pallet].self, from: json)
        }
        catch {
            return
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
