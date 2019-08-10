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
    var currentTargetIndex =  0
    let map = SCNScene(named: "galacticmap.scn")!
    var rotationNode: SCNNode { return  (map.rootNode.childNode(withName: "rotateNode", recursively: true)!) }
    // create target indicator
//    var oldTargetIndicator = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius*3))
    var currentLocationIndicator = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius*2))

    var currentAngleY: Float = 0.0

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
        let actions = [growAnim, fadeAnim]
        let growAndFade = SCNAction.group(actions)
        let reset = SCNAction.scale(to: 1.0, duration: 0)
        let reset2 = SCNAction.fadeIn(duration: 0)
        let resetActions = [reset, reset2]
        let shrinkAndMakeVisible = SCNAction.group(resetActions)
        let sequence = SCNAction.sequence([growAndFade, shrinkAndMakeVisible])
        let repeatedSequence = SCNAction.repeatForever(sequence)

//    oldTargetIndicator.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
//    oldTargetIndicator.runAction(repeatedSequence)
//    rotationNode.addChildNode(oldTargetIndicator)

    currentLocationIndicator.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
    currentLocationIndicator.runAction(repeatedSequence)
    rotationNode.addChildNode(currentLocationIndicator)

      func rotateObject(_ gesture: UIPanGestureRecognizer) {

            let translation = gesture.translation(in: gesture.view!)
            var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
            newAngleY += currentAngleY

            rotationNode.eulerAngles.y = newAngleY

            if(gesture.state == .ended) { currentAngleY = newAngleY }

            print(rotationNode.eulerAngles)
        }
        // and make all node geometries independent entities, so they can be highlighted

        for nodeNumber in 1...128 {
            let currentNode = sectorGrid(number: nodeNumber)
            let newMaterial = SCNMaterial()
            newMaterial.diffuse.contents = UIColor.green
            let newMaterials = [newMaterial]
            currentNode?.geometry?.materials = newMaterials
        }
        
        
   
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func sectorGrid(number: Int) -> SCNNode? {
        let nodeNumberString = String(number+1)
        return  map.rootNode.childNode(withName: nodeNumberString, recursively: true)
    }
    
    func gridMaterial(color: UIColor) -> [SCNMaterial] {
        let newMaterial = SCNMaterial()
        newMaterial.diffuse.contents = color
        return [newMaterial]
    }
    
    internal func unHilightGrid(number: Int) {
        let grid = sectorGrid(number: number)
        grid?.geometry?.materials = gridMaterial(color: .green)
    }
    
    // Public functions
    func updateDisplay(withModel: GalaxyMapModel) {

    }
    
    func hilightGrid(number: Int, color: UIColor) {
        unHilightGrid(number: currentTargetIndex)
        let grid = sectorGrid(number: number)
        grid?.geometry?.materials = gridMaterial(color: color)
        currentTargetIndex = number
    }
    
  
    
  
    

}
