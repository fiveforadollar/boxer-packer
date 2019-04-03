//
//  AROutputViewController.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-01-14.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import UIKit
import ARKit
import Foundation
import SwiftyJSON
import ChameleonFramework

class AROutputViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var sceneView: ARSCNView!
//    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var collectionViewPallet: UICollectionView!
    
    @IBOutlet weak var collectionViewBox: UICollectionView!
    
    @IBOutlet weak var buttonConfirmPlane: UIButton!
    
    var set = Set()
    var palletCenter = SCNVector3(0,0,0)
    var selectedPalletID : Int?
    var setData : String!
    var available_colors = Colors.getAllColors()
    
    private let itemsPerRow = 6
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    // MARK: - Gestures, Actions
    
    @IBAction func confirmPlane(_ sender: Any) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
        
        // remove plane node, add new plane with texture, or just edit it
        let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true)
        let pallet = SCNBox(width: CGFloat(Constants.palletLength/2), height: CGFloat(Constants.palletWidth/2), length: CGFloat(0.1/2), chamferRadius: 0)
        pallet.materials.first?.diffuse.contents = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.85)
        let palletNode = SCNNode(geometry: pallet)
        palletNode.name = "pallet"
        palletNode.position = SCNVector3(0,0,-0.05/2)
        planeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0)
        planeNode?.addChildNode(palletNode)
        
        DispatchQueue.main.async {
            self.buttonConfirmPlane.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
        configureLighting()
        
        collectionViewPallet.backgroundColor = UIColor(white: 1, alpha: 0.5)
        collectionViewBox.backgroundColor = UIColor(white: 1, alpha: 0.5)
        collectionViewBox.isHidden = true
        
        collectionViewPallet.delegate = self
        collectionViewPallet.dataSource = self
        selectedPalletID = 0
        
        // start: to use json from file
//        if let path = Bundle.main.path(forResource: "set0", ofType: "json")
//        {
//            do {
//                let fileUrl = URL(fileURLWithPath: path)
//                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
//                set = parseJSON(data, set, output: "AR")
//            }
//            catch {
//
//            }
//        }
        // end
        
        let json = setData.data(using: .utf8)!
        set = parseJSON(json, set, output: "AR")
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonConfirmPlane.isHidden = true
        setUpSceneView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
    }
    
    // ADD OBJECTS
    
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        let width = CGFloat(0.02)
        let height = CGFloat(0.04)
        let length = CGFloat(0.06)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y + Float(height/2)
        let z = translation.z
        
        print("tap")
        
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        
        boxNode.position = SCNVector3(x,y,z)
        boxNode.name = "box"
        sceneView.scene.rootNode.addChildNode(boxNode)
  
    }
    
    func addBoxesForPallet(_ palletID: Int){
        // remove box nodes from previously selected pallet
        print("in addBoxesForPallet ")
        guard let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true)
            else{
                print("plane does not exist")
                return
        }
        let children = planeNode.childNodes
        
        for child in children {
            guard let name = child.name
                else{
                    print("no name")
                    return
            }
            if name.contains("box") {
                child.removeFromParentNode()
            }
        }
        let pallet = set.pallets[palletID]
        
        for i in 0...(pallet.items.count - 1){
            
            let w = CGFloat(pallet.items[i].width/2)
            let h = CGFloat(pallet.items[i].height/2)
            let l = CGFloat(pallet.items[i].length/2)
            
            let x = pallet.items[i].position[0]/2
            let y = pallet.items[i].position[1]/2
            let z = pallet.items[i].position[2]/2
            
            let box = SCNBox(width: w, height: h, length: l, chamferRadius: 0)
            
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3(x,y,z)
            boxNode.name = "box" + String(i)
            boxNode.geometry?.firstMaterial?.diffuse.contents = available_colors[i]
            planeNode.addChildNode(boxNode)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        
        if collectionView == self.collectionViewPallet{
            print(indexPath)
            print(set.pallets.count)
            print(indexPath.item)
            addBoxesForPallet(indexPath.item)
            selectedPalletID = indexPath.item
            self.collectionViewBox.isHidden = false
            self.collectionViewBox?.reloadData()
        }
        else{
            // highlight selected box
            let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true)
            
            let name = "box" + String(indexPath.item)
            guard let children = planeNode?.childNodes
                else{
                    return
            }
            for child in children{
                if child.name == name{
                    child.geometry?.firstMaterial?.diffuse.contents = FlatYellow()
                }
                else if child.name != "pallet" {
                    child.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.7)
                }
            }
            
            // Unselect colour all other collection view box cells
            for boxCell in self.collectionViewBox.visibleCells {
                if boxCell.isSelected == false {
                    boxCell.backgroundColor = nil
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool{
        if collectionView == self.collectionViewBox{
            if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
                collectionView.deselectItem(at: indexPath, animated: true)
                
                
                    let pallet = set.pallets[selectedPalletID!]
                    for i in 0...(pallet.items.count - 1){
                        guard let child = sceneView.scene.rootNode.childNode(withName: "box"+String(i), recursively: true)
                            else {
                                return false
                                // node with name not found
                        }
                        child.geometry?.firstMaterial?.diffuse.contents = available_colors[i]
                    }
                
                    // Recolour all other collection view box cells
                    for cellIndex in 0..<self.collectionViewBox.visibleCells.count {
                        let boxCell = self.collectionViewBox.visibleCells[cellIndex]
                        boxCell.backgroundColor = available_colors[cellIndex]
                    }
                
                return false
            }
            else{
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                
                return true
            }
        }
        return true
    }
    
}

extension AROutputViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("in renderer")
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        planeNode.name = "plane"
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
        
        DispatchQueue.main.async {
            self.buttonConfirmPlane.isHidden = false
        }
        
        palletCenter = planeNode.position
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
        palletCenter = planeNode.position
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension AROutputViewController: UICollectionViewDataSource{
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
            cell.palletNumber.text = String(indexPath.item + 1)
    //        cell.backgroundColor = .black
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boxCell",for: indexPath) as! BoxCollectionViewCell
            
            let photo = UIImage(named: "box.png")
            
            cell.boxImageView.image = photo
            cell.backgroundColor = available_colors[indexPath.item]
            
            return cell
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension AROutputViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let paddingSpace = CGFloat(0)
        let availableWidth = sceneView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
