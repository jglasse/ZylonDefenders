//
//  GalaxyMapDisplay.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/29/19.
//  Copyright © 2023 Jeffery Glasse. All rights reserved.
//  Container class for galacic map scene, because subnclassing SCNScene is not reccommended.

import Foundation
import SceneKit
import SpriteKit

class GalacticMapDisplay {
    var myPanRecognizer: UIPanGestureRecognizer!
    var currentShipSectorIndex = 0
    var currentTargetIndex =  0
    var threeDMode = true
    let map = SCNScene(named: "galacticmap.scn")!
    var rotationNode: SCNNode { return  (map.rootNode.childNode(withName: "rotateNode", recursively: true)!) }
    let cameraNode = SCNNode()

    // create target indicator
    var currentAngleY: Float = 0.0

    @objc func rotateObject(_ gesture: UIPanGestureRecognizer) {

        let translation = gesture.translation(in: gesture.view!)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleY += currentAngleY

        rotationNode.eulerAngles.y = newAngleY

        if gesture.state == .ended { currentAngleY = newAngleY }

        print(rotationNode.eulerAngles)
    }

    init() {

    myPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotateObject(_:)))
    cameraNode.camera = SCNCamera()
    cameraNode.name = "gCam"

        self.map.rootNode.addChildNode(cameraNode)

        let internalRot = map.rootNode.childNode(withName: "internalRot", recursively: true)
        internalRot?.rotation = SCNVector4Make(0, 0, 1, 3.141)

    // point the camera at the galaxy map
    let camConstraint = SCNLookAtConstraint(target: self.map.rootNode)
    camConstraint.isGimbalLockEnabled = true
    cameraNode.constraints = [camConstraint]

    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: -8, z: 5.2)

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

    internal func unHilightGrid(gridNumber: Int) {

        let gColor = UIColor.green
        let grid = sectorGrid(number: gridNumber)
        grid?.geometry?.materials = gridMaterial(color: gColor)
    }

    // Public functions
    func updateDisplay(galaxyModel: GalaxyMapModel, shipSector: Int, targetSector: Int) {
        // iterate over grids
        for i in 1...128 {

            let sectorString = "\(i)"
            let currentGrid = map.rootNode.childNode(withName: sectorString, recursively: true)
            for gridElement in currentGrid!.childNodes {
                gridElement.removeFromParentNode()
            }
            let sectorObjectNode = GalaxyBlip(sectorType: galaxyModel.map[i-1].sectorType)
            currentGrid?.addChildNode(sectorObjectNode)
        }
        setNewShipCurrentGrid(number: shipSector, color: .white)
        setNewTargetGrid(number: targetSector, color: .red)

    }

    func addIcon(at node: SCNNode, icon: String) {
        let newPlane = SCNPlane(width: 0.35, height: 0.35)
        newPlane.materials = [SCNMaterial()]
        newPlane.materials.first?.diffuse.contents = UIImage(named: icon)
        newPlane.materials.first?.isDoubleSided = true
        let icon = SCNNode(geometry: newPlane)
        icon.rotation = SCNVector4(1, 0, 0, Float.pi/2)
        node.addChildNode(icon)
        let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 1)
        let forever = SCNAction.repeatForever(action)
        icon.runAction(forever)
    }

    func setNewTargetGrid(number: Int, color: UIColor) {
        unHilightGrid(gridNumber: currentTargetIndex)
        let grid = sectorGrid(number: number)
        grid?.geometry?.materials = gridMaterial(color: color)
        currentTargetIndex = number

    }

    func setNewShipCurrentGrid(number: Int, color: UIColor) {
        unHilightGrid(gridNumber: currentShipSectorIndex)
        let grid = sectorGrid(number: number)
        grid?.geometry?.materials = gridMaterial(color: color)
        currentShipSectorIndex = number
    }

}
