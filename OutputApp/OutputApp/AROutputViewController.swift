//
//  AROutputViewController.swift
//  OutputApp
//
//  Created by Kathy Huang on 2019-01-14.
//  Copyright © 2019 fiveforadollar. All rights reserved.
//

import UIKit
import ARKit

class AROutputViewController: UIViewController {
    
    // MARK - Properties
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK - Gestures, Actions
    
    @IBAction func ARToChooseButton(_ sender: Any) {
        performSegue(withIdentifier: "ARToChoose", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
         configureLighting()
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
        
        addTapGestureToSceneView()
        
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // ADD OBJECTS
    
    @objc func addBoxToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
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
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AROutputViewController.addBoxToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
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


// TODO:
// 1 Parse output of algorithm for box locations and orientations
// 2 Choose which pallet to display
// 3 Display on any flat surface, set the center of the surface to center of bottom of pallet
//  (sizes may be different; can use hittest select plane)
// 4 Calculate position of front left corner of pallet in ARSCNView
// 5 For each box for that pallet, calculate its position in ARSCNView given relative location
