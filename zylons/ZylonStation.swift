//
//  SpaceStation.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 5/10/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class ZylonStation: SectorObject {
    var currentSpeed = 0.0
    var shieldStrength = 100
    var weaponType = 0
    var zylonTargetPosition = vector3(0.0, 0.0, 0.0)

    override init() {
        super.init()
        self.sectorObjectType = .zylonStation
        let zylonStationScene = SCNScene(named: "zylonStation.scn")
        let zylonStation = zylonStationScene?.rootNode.childNode(withName: "Zstation", recursively: true)
        let stationShape = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        let stationPhysicsShape = SCNPhysicsShape(geometry: stationShape, options: nil)
        let zylonStationHolderNode = SCNNode()
        zylonStationHolderNode.addChildNode(zylonStation!)
        self.addChildNode(zylonStationHolderNode)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: stationPhysicsShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = objectCategories.enemyShip
        self.physicsBody?.contactTestBitMask = objectCategories.zylonFire
        self.name = "zylonStation"
       // self.worldOrientation = SCNVector4(0, 0, 1, Float.pi)
        self.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        self.worldPosition = SCNVector3Make(0,0,-200)
        self.scale = SCNVector3Make(0.1, 0.1, 0.1)
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 58)
        let forever = SCNAction.repeatForever(action)
        zylonStation?.runAction(forever)
        
        

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
