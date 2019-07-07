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
    // create target indicator
    var targetIndicator = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius*3))
    var currentLocationIndicator = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius*2))

    
    
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
    
        
    // add the target and current position nodes
        let growAnim = SCNAction.scale(by: 2.5, duration: 1.0)
        let fadeAnim = SCNAction.fadeOut(duration: 1.0)
        let actions = [growAnim,fadeAnim]
        let growAndFade = SCNAction.group(actions)
        let reset = SCNAction.scale(to: 1.0, duration: 0)
        let reset2 = SCNAction.fadeIn(duration: 0)
        let resetActions = [reset,reset2]
        let shrinkAndMakeVisible = SCNAction.group(resetActions)
        let sequence = SCNAction.sequence([growAndFade, shrinkAndMakeVisible])
        let repeatedSequence = SCNAction.repeatForever(sequence)

    targetIndicator.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
    targetIndicator.runAction(repeatedSequence)
    rotationNode.addChildNode(targetIndicator)
        
    currentLocationIndicator.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
    currentLocationIndicator.runAction(repeatedSequence)
    rotationNode.addChildNode(currentLocationIndicator)

    
    
    
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateDisplay(withModel: GalaxyMapModel){
        
    }
    
}
