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
import ChameleonFramework

class LayoutViewController: UIViewController {

    // Scene view that holds the layout scene
    @IBOutlet weak var scnView: SCNView!
    
    // Pallets data structure to be filled by incoming data
    var pallets = [Pallet]()
    
    // Counter to keep track of how many pallet icons we have rendered
    var curNumPallets = 0
    
    // Get all colors from color library for box identification
    var available_colors = Colors.getAllColors()
    
    // Collection view bar containing the pallet selection interface
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize collectionVIew
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
        // Create scene
        let scene = SCNScene(named:"Layout.scnassets/Scenes/LayoutScene.scn")!
    
        // Set the scene to the view
        scnView.scene = scene

        // Allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
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
        
//        // Draw pallet selection options
//        for pallet in pallets {
//            // Draw pallet selection options
//            let newPalletIcon = UITableViewCell()
//            let photo = UIImage(named: "art.scnassets/pallet-icon.png")
//
//            newPalletIcon.imageView.image = photo
//
//            let insertPath = IndexPath(row: self.curNumPallets, section: 0)
//            comments.append(your_object) //add your object to data source first
//            self.collectionView?.insertItems(at: [indexPath])
//            collectionVIew.addChild
//
//        }
    
        // Draw each box in their corresponding pallets
        for box in (pallets[0].items) {
            let cube = SCNBox(width: CGFloat(box.width), height: CGFloat(box.height), length: CGFloat(box.length), chamferRadius: 0.0)
            // Create the cube's pivot point to be its back left corner
            let cubePivot = SCNMatrix4MakeTranslation(-(box.width/2), -(box.height/2), (box.length/2))
            let cubePosition = SCNVector3 (
                x: box.position[0],
                y: box.position[1],
                z: box.position[2]
            )
            
            // Set cube's color to be unique - take and remove from master list of colors
            if available_colors.count > 0 {
                let colorIndex = Int.random(in: 0..<available_colors.count)
                let cubeColor = available_colors[colorIndex]
                available_colors.remove(at: colorIndex)
                let cubeMaterial = SCNMaterial()
                cubeMaterial.diffuse.contents = cubeColor
                cubeMaterial.locksAmbientWithDiffuse = true
                cube.materials = [cubeMaterial]
            }
            else {
                print("Error: Max number of boxes per pallet reached!")
            }

            // Set the cube's dimensions, pivot and position through its node
            let cubeNode = SCNNode(geometry: cube)
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
    
    // Handle gestures, allows:
    // 1. Pinch for zooming
    // 2. Tap for selection
    // 3. Panning
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

extension LayoutViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("pallet count: ", pallets.count)
        return pallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! CollectionImageCell
    
        let photo = UIImage(named: "pallet-icon.png")
        
        cell.imageView.image = photo
        
        return cell
    }
}
