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
    enum ManeuverType {
        case zig
        case zag
        case fullstop
    }
    enum ShipType {
        case scout
        case fighter
        case destroyer
    }
    var shiptype: ShipType = .scout
	var currentSpeed = 0.0
	var shieldStrength = 100
	var weaponType = 0
    var currentManeuverType: ManeuverType = .fullstop

    var inCurrentManeuver  = false
    var cyclesUntilNextImpulseTurn = 1
    var speedVector =  vector3(0.0, 0.0, 0.0)
    var targetspeedVector = vector3(0.0, 0.0, 1.0)

    var currentlyShooting = false
    var cyclesUntilFireTorpedo: Float = 30.0

	var zylonTargetPosition = vector3(10.0, 0.0, 0.0)

	var range = [Float]()

    func fireTorpedo() {
        let torpedoNode = Torpedo(designatedTorpType: .humon)
        let parentNode = self.parent!
        let driftAmount: Float = 2
        let offset: Float = 4
        let forceAmount: Float = 55
     //   torpedoNode.worldPosition.z += offset // place the torpedo in front of the ship
        parentNode.addChildNode(torpedoNode)
        torpedoNode.worldPosition = self.worldPosition
        torpedoNode.physicsBody?.applyForce(SCNVector3Make(-driftAmount, 1.7, forceAmount), asImpulse: true)

    }
    func maneuver() {

        //MOVE SHIP LOGIC
        //if not currently maneuvering, begin executing maneuver. When maneuver is complete, create new maneuver with a random duration between minManeuverInterval and maxManeuverInterval

        if currentManeuverType == .fullstop {

         let maneuverDuration = TimeInterval(randRange(lower: 1.0, upper: 3.0))
         var currentManeuver: SCNAction
         let randomYDelta = randRange(lower: -10, upper: 10)
         let randomXDelta = randRange(lower: 0, upper: 10)
         if self.worldPosition.x < 0 {
            self.currentManeuverType = .zig
            currentManeuver = SCNAction.move(by: SCNVector3(30.0 + randomXDelta, randomYDelta, 0), duration: maneuverDuration)
            } else {
            self.currentManeuverType = .zag
            currentManeuver = SCNAction.move(by: SCNVector3(-30.0, randomYDelta, 0), duration: maneuverDuration)
        }
            let fullStop = { () -> Void in
                self.currentManeuverType = .fullstop
                self.inCurrentManeuver = false

            }
            self.inCurrentManeuver = true
            currentManeuver.timingMode = .easeInEaseOut
            self.runAction(currentManeuver, completionHandler: fullStop)

        } else
            if self.inCurrentManeuver {
                cyclesUntilNextImpulseTurn  -= 1
        }

        //FIRE TORPEDO LOGIC
        //if I'm not currently counting down to fire, start a new counter, with a random value between minShootInterval and maxShootInterval
        print("cyclesUntilFireTorpedo: \(cyclesUntilFireTorpedo)")
        if cyclesUntilFireTorpedo  == 0 {
            self.fireTorpedo()

            cyclesUntilFireTorpedo = randRange(lower: Constants.minHumonTorpedoCycles, upper: Constants.maxHumonTorpedoCycles)
        } else {
            cyclesUntilFireTorpedo  -= 1
        }

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
        self.worldOrientation = SCNVector4(0, 0, 1, 0)
        self.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        self.position = SCNVector3Make(0, 0, -30)
        self.scale = SCNVector3Make(1, 1, 1)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
