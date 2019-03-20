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
    var set = Set()
    
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
        {
            "datetime": "2019-03-18T16:51:55Z",
            "pallets": [
                {
                    "id": 0,
                    "items": [
                        {
                            "height": 10,
                            "id": 3,
                            "length": 10,
                            "position": [
                                500,
                                600,
                                0.0
                            ],
                            "width": 20
                        },
                        {
                            "height": 51,
                            "id": 2,
                            "length": 39,
                            "position": [
                                70.0,
                                0.0,
                                0.0
                            ],
                            "width": 47
                        }
                    ],
                    "numBoxes": 2
                },
                {
                    "id": 1,
                    "items": [
                        {
                            "height": 20,
                            "id": 1,
                            "length": 80,
                            "position": [
                                0.0,
                                0.0,
                                0.0
                            ],
                            "width": 10
                        }
                    ],
                    "numBoxes": 1
                }
            ],
            "setID": 0
        }
        """.data(using: .utf8)!
        set = parseJSON(json, set, output: "3D")
        
        // Catch in case there are no pallets
        if set.pallets.count <= 0 {
            return
        }
    
        // Initially, the 0th pallet is selected
        let palletId = 0
        for box in (set.pallets[palletId].items) {
            let cubeNode = createBox(box)
            scene.rootNode.addChildNode(cubeNode)
        }
    }
    
    // Generates and returns a SCNNode, given the Box parameters
    func createBox(_ box: Box) -> SCNNode {
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
        cubeNode.name = "box"
        
        return cubeNode
    }
    
    func addBoxesForPallet(_ palletID: Int){
        // Remove box nodes from previously selected pallet
        for child in scnView.scene!.rootNode.childNodes {
            if child.name == "box" {
                child.removeFromParentNode()
            }
        }
        
        // Add all boxes in newly selected pallet
        for box in set.pallets[palletID].items {
            let box = createBox(box)
            scnView.scene!.rootNode.addChildNode(box)
        }
    }
    
    // Handle gestures, allows:
    // 1. Pinch for zooming
    // 2. Tap for selection
    // 3. Panningrs
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
        return set.pallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! CollectionImageCell
        
        let photo = UIImage(named: "pallet.png")
        
        cell.imageView.image = photo
        
        return cell
    }
}

extension LayoutViewController: UICollectionViewDelegate {
    // Pallet icon clicked - changing pallets
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        addBoxesForPallet(indexPath.item)
    }
}
