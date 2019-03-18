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

class AROutputViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var buttonConfirmPlane: UIButton!
    
    var set : Set!
    var palletCenter = simd_float3(0,0,0)
    let arr = [1,2,3,4,5]
    private let itemsPerRow = 4
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    // MARK: - Gestures, Actions
    
//    @IBAction func ARToChooseButton(_ sender: Any) {
//        performSegue(withIdentifier: "ARToChoose", sender: self)
//    }
//
    
    
    @IBAction func confirmPlane(_ sender: Any) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
        configureLighting()
        
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let json = """
        {
            "datetime": "2019-03-18T16:51:55Z",
            "pallets": [
                {
                    "id": 0,
                    "items": [
                        {
                            "height": 0.01,
                            "id": 3,
                            "length": 0.01,
                            "position": [
                                0.0,
                                0.0,
                                0.0
                            ],
                            "width": 0.01
                        },
                        {
                            "height": 0.51,
                            "id": 2,
                            "length": 0.39,
                            "position": [
                                0.01,
                                0.0,
                                0.0
                            ],
                            "width": 0.47
                        }
                    ],
                    "numBoxes": 2
                },
                {
                    "id": 1,
                    "items": [
                        {
                            "height": 0.51,
                            "id": 1,
                            "length": 0.39,
                            "position": [
                                0.0,
                                0.0,
                                0.0
                            ],
                            "width": 0.47
                        }
                    ],
                    "numBoxes": 1
                }
            ],
            "setID": 0
        }
        """.data(using: .utf8)!
        
        parseJSON(json)
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
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = true
        
        let spotLight = SCNLight();
        spotLight.type = SCNLight.LightType.directional;
        
        let spotNode = SCNNode();
        spotNode.light = spotLight;
        spotNode.position = SCNVector3(x: -30, y: 30, z: 60);
        sceneView.scene.rootNode.addChildNode(spotNode);
        
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
        self.collectionView?.reloadData()
    }
    
    func addBoxesForPallet(_ palletID: Int){
        // remove box nodes from previously selected pallet
        print("in addBoxesForPallet ")
        let children = sceneView.scene.rootNode.childNodes
        for child in children{
            if child.name == "box"{
                child.removeFromParentNode()
            }
        }
        let pallet = set.pallets[palletID]
        print("got pallet \(palletID) in addBoxesForPallet")
        print("pallet.items.count = \(pallet.items.count)")
        for i in 0...(pallet.items.count - 1){
            print("box number \(i)")
            let width = CGFloat(pallet.items[i].width)
            let height = CGFloat(pallet.items[i].height)
            let length = CGFloat(pallet.items[i].length)
            
            let x = pallet.items[i].position[0] + palletCenter.x
            let y = pallet.items[i].position[1] + palletCenter.y
            let z = pallet.items[i].position[2] + palletCenter.z
            print("x: \(x), y: \(y), z: \(z)")
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
            let boxNode = SCNNode(geometry: box)
            
            boxNode.position = SCNVector3(x,y,z)
            boxNode.name = "box"
            sceneView.scene.rootNode.addChildNode(boxNode)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        print(indexPath)
        print(set.pallets.count)
        print(indexPath.item)
        addBoxesForPallet(indexPath.item)
        
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
        
        palletCenter = planeAnchor.center
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

// MARK: - Box Packing
extension AROutputViewController{
    func parseJSON(_ json: Data){
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            set = try decoder.decode(Set.self, from: json)
        }
        catch {
            print("caught: \(error)")
        }
    }
}

extension AROutputViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("pallet count: ", set.pallets.count)
        return set.pallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! CollectionImageCell
        //2
        print("pallet iconnnnnn")
        let photo = UIImage(named: "pallet-icon.png")
        
        cell.imageView.image = photo
        
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension AROutputViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = sceneView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
