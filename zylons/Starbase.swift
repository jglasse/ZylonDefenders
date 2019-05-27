//
//  HumonShip.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 6/18/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class Starbase: SectorObject {
    
    var shieldStrength = 100
    var isRefueling = false
   
    
    override init() {
        super.init()
        self.sectorObjectType = .zylonStation //
        let stationScene = SCNScene(named: "zylonStation.scn")
        let station = stationScene?.rootNode.childNode(withName: "station", recursively: true)
        //let droneShape = SCNBox(width: 10, height: 5, length: 5, chamferRadius: 0)
        //let dronePhysicsShape = SCNPhysicsShape(geometry: droneShape, options: nil)
        self.addChildNode(station!)
//        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: dronePhysicsShape)
//        self.physicsBody?.isAffectedByGravity = false
//        self.physicsBody?.friction = 0
//        self.physicsBody?.categoryBitMask = objectCategories.enemyShip
//        self.physicsBody?.contactTestBitMask = objectCategories.zylonFire
//        self.name = "humonShip"
        self.worldOrientation = SCNVector4(0, 0, 1, Float.pi)
      //  self.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        self.worldPosition = SCNVector3Make(0, 0, -60)
        self.scale = SCNVector3Make(0.06, 0.06, 0.06)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
