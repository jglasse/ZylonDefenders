//
//  HumonShip.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 6/18/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class HumonShip: SCNNode {

    enum ShipType {
        case scout
        case fighter
        case destroyer
    }

    var shiptype: ShipType = .scout
	var currentSpeed = 0.0
	var shieldStrength = 100
	var weaponType = 0
	// orintation angles
	var theta = 0.0
	var phi = 0.0
	// current speed and target speed

    struct navigationSystem {
        var cyclesUntilNextImpulseTurn = 1
        var speedVector =  vector3(0.0, 0.0, 0.0)
        var targetspeedVector = vector3(0.0, 0.0, 1.0)

    }

	var zylonTargetPosition = vector3(10.0, 0.0, 0.0)

	var range = [Float]()

	func newTargetSpeedVector() {
	}

    override init() {
        super.init()
        let humonshipScene = SCNScene(named: "Humon.scn")
        let humonShip = humonshipScene?.rootNode.childNodes[0]
        let droneShape = SCNBox(width: 10, height: 5, length: 5, chamferRadius: 0)
        let dronePhysicsShape = SCNPhysicsShape(geometry: droneShape, options: nil)
        self.addChildNode(humonShip!)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: dronePhysicsShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = 0b00000010
        self.physicsBody?.contactTestBitMask = 0b00000010
        self.name = "drone"
        self.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        self.position = SCNVector3Make(0, 0, -30)
        self.scale = SCNVector3Make(1, 1, 1)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
