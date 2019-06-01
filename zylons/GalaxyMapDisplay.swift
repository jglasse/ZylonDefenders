//
//  GalaxyMapDisplay.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/29/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//  Container class for galacic map scene, because subnclassing SCNScene is not reccommended.

import Foundation
import SceneKit

class GalacticMapDisplay {
    let map = SCNScene(named: "galacticmap.scn")!
    var rotationNode: SCNNode { return  (map.rootNode.childNode(withName: "rotateNode", recursively: true)!) }
    
    init() {
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.name = "gCam"
    
        self.map.rootNode.addChildNode(cameraNode)
        rotationNode.rotation = SCNVector4Make(0, 0, 1, 3.141)
    
    //point the camera at the galaxy map
    let camConstraint = SCNLookAtConstraint(target: self.map.rootNode)
    camConstraint.isGimbalLockEnabled = true
    cameraNode.constraints = [camConstraint]
    
    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: -8, z: 5.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
