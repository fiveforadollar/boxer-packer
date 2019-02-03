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
    var pallets = [Pallet]()
    let arr = [1,2,3,4,5]
    private let itemsPerRow = 4
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Gestures, Actions
    
    @IBAction func ARToChooseButton(_ sender: Any) {
        performSegue(withIdentifier: "ARToChoose", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
        configureLighting()
        
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let json = """
        [
            {
                "id": 0,
                "items":
                [
                    {
                        "id": 0,
                        "length": 5,
                        "width": 10,
                        "height": 11,
                        "position": [0, 0, 11]
                    },
                    {
                        "id": 1,
                        "length": 15,
                        "width": 9,
                        "height": 7,
                        "position": [0, 15, 0]
                        
                    },
                    {
                        "id": 2,
                        "length": 15,
                        "width": 9,
                        "height": 7,
                        "position": [12, 0, 0]
                    },
                    {
                        "id": 4,
                        "length": 12,
                        "width": 15,
                        "height": 11,
                        "position": [0, 0, 0]
                    }
                ]
            },
            {
                "id": 1,
                "items":
                [
                    {
                        "id": 3,
                        "length": 40,
                        "width": 40,
                        "height": 50,
                        "position": [0, 0, 0]
                    }
                ]
            }
        ]
        """.data(using: .utf8)!
        
        parseJSON(json)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        sceneView.scene.rootNode.addChildNode(boxNode)
        self.collectionView?.reloadData()
    }
    

    
}

extension AROutputViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
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
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
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
        do {
            pallets = try decoder.decode([Pallet].self, from: json)
        }
        catch {
            return
        }
    }
}

extension AROutputViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("pallet count: ", arr.count)
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! CollectionImageCell
        //2
        let photo = UIImage(named: "pallet-icon")
     
//        cell.backgroundColor = .white
        //3
        cell.imageView.image = photo
        
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension AROutputViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = sceneView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
//    //3
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

}
