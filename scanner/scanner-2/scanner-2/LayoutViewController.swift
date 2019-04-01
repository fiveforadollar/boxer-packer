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
    
    @IBOutlet weak var collectionViewPallet: UICollectionView!
    
    @IBOutlet weak var collectionViewBox: UICollectionView!
    
    var selectedPalletID : Int?
    
    private let itemsPerRow = 4
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var setData : String!
    // Pallets data structure to be filled by incoming data
    var set = Set()
    
    // Get all colors from color library for box identification
    var available_colors = Colors.getAllColors()
    
    // Collection view bar containing the pallet selection interface
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize collectionVIew
        collectionViewPallet.backgroundColor = UIColor(white: 1, alpha: 0.5)
        collectionViewBox.backgroundColor = UIColor(white: 1, alpha: 0.5)
        selectedPalletID = 0
        // Create scene
        let scene = SCNScene(named:"LayoutScene.scn")!

        // Set the scene to the view
        scnView.scene = scene

        // Allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
//         Get pallet/box data to be visualized
//         start: to use json from file
                if let path = Bundle.main.path(forResource: "test", ofType: "json")
                {
                    do {
                        let fileUrl = URL(fileURLWithPath: path)
                        let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                        set = parseJSON(data, set, output: "3D")
                    }
                    catch {
        
                    }
                }
//         end
        
//        let json = setData.data(using: .utf8)!
//        set = parseJSON(json, set, output: "3D")
        
        // Catch in case there are no pallets
        if set.pallets.count <= 0 {
            return
        }
    
        // Initially, the 0th pallet is selected
        addBoxesForPallet(0)
    }
    
    // Generates and returns a SCNNode, given the Box parameters
    func createBox(_ box: Box, _ boxNum: Int) -> SCNNode {
        let cube = SCNBox(width: CGFloat(box.width), height: CGFloat(box.height), length: CGFloat(box.length), chamferRadius: 0.0)
        // Create the cube's pivot point to be its back left corner
        let cubePivot = SCNMatrix4MakeTranslation(-(box.width/2), -(box.height/2), -(box.length/2))
        let cubePosition = SCNVector3 (
            x: box.position[0],
            y: box.position[1],
            z: box.position[2]
        )
        
        // Set cube's color to be unique - take and remove from master list of colors
        if boxNum < available_colors.count {
            let cubeColor = available_colors[boxNum]
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
            guard let name = child.name
                else{
                    print("no name")
                    return
            }
            if name.contains("box") {
                child.removeFromParentNode()
            }
        }
        
        // Add all boxes in newly selected pallet
        let pallet = set.pallets[palletID]
        for i in 0...(pallet.items.count - 1){
            
            let box = createBox(pallet.items[i], i)
            box.name = "box" + String(i)
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
        if collectionView == self.collectionViewPallet {
            print("pallet count: ", set.pallets.count)
            return set.pallets.count
        }
        else {
            if selectedPalletID != nil{
                return set.pallets[selectedPalletID!].items.count
            }
            else {
                return 0
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewPallet {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "palletCell",for: indexPath) as! CollectionImageCell
            
            let photo = UIImage(named: "pallet.png")
            
            cell.imageView.image = photo
            //        cell.backgroundColor = .black
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boxCell",for: indexPath) as! BoxCollectionViewCell
            
            let photo = UIImage(named: "box.png")
            
            cell.boxImageView.image = photo
            
            return cell
        }
    }
}

extension LayoutViewController: UICollectionViewDelegate {
    // Pallet icon clicked - changing pallets
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        if collectionView == self.collectionViewPallet{
            print(indexPath)
            print(set.pallets.count)
            print(indexPath.item)
            addBoxesForPallet(indexPath.item)
            selectedPalletID = indexPath.item
            self.collectionViewBox?.reloadData()
        }
        else{
            // highlight selected box
            
            let name = "box" + String(indexPath.item)
          
            for child in scnView.scene!.rootNode.childNodes {
                if child.name == name{
                    child.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                }
                else if child.name != "pallet" {
                    child.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.7)
                }
            }
            
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool{
        if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            if collectionView == self.collectionViewBox{
                let pallet = set.pallets[selectedPalletID!]
                for i in 0...(pallet.items.count - 1){
                    guard let child = scnView.scene!.rootNode.childNode(withName: "box"+String(i), recursively: true)
                        else {
                            return false
                            // node with name not found
                    }
                    child.geometry?.firstMaterial?.diffuse.contents = available_colors[i]
                }
            }
            
            return false
        }
        else{
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            return true
        }
        
    }
}

extension LayoutViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = scnView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
