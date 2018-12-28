//
//  Grid.swift
//  NextReality_Tutorial4
//
//  Created by Ambuj Punn on 5/2/18.
//  Copyright © 2018 Ambuj Punn. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ARPlaneAnchor {
    var width: Float { return self.extent.x * 100}
    var length: Float { return self.extent.z * 100}
}

class Grid : SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) -> String {
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.extent.z);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
        //if let textGeometry = self.childNode(withName: "textNode", recursively: true)?.geometry as? SCNText {
        //    let widthString = String(format: "%.1f\"", anchor.width)
        //    let lengthString = String(format: "%.1f\"", anchor.length)
        //}
        return String(format: "%.1f\"", anchor.width) + " by " + String(format: "%.1f\"", anchor.length)
    }
    
    private func setup() {
        planeGeometry = SCNPlane(width: CGFloat(anchor.width), height: CGFloat(anchor.length))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"overlay_grid.png")
        
        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        
        addChildNode(planeNode)
    }
}
