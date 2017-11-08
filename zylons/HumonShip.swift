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

         let maneuverDuration = TimeInterval(randRange(lower: 1, upper: 3))
         var currentManeuver: SCNAction
         let yDelta: Float = randRange(lower: -30, upper: 30)
         var xDelta: Float
         var zDelta: Float = 0
            print("drone position: \(self.worldPosition)")
        if self.worldPosition.z  < -20 {
          zDelta = randRange(lower: -1, upper: 45)
            } else {
            zDelta = randRange(lower: -25, upper: 20)
            }
         xDelta = 0
         if self.worldPosition.x < 0 {
            self.currentManeuverType = .zig
            xDelta = randRange(lower: 20, upper: 40)
         } else {
            self.currentManeuverType = .zag
            xDelta = randRange(lower: -40, upper: -20)

        }
            let fullStop = { () -> Void in
                self.currentManeuverType = .fullstop
                self.inCurrentManeuver = false

            }
            let targetWorldVector = SCNVector3(x: self.worldPosition.x+xDelta, y: self.worldPosition.y+yDelta, z: self.worldPosition.z+zDelta)
            let targetObjectsNodeVector = self.parent?.convertPosition(targetWorldVector, from: self.parent?.parent)

            currentManeuver = SCNAction.move(to: targetObjectsNodeVector!, duration: maneuverDuration)
           // currentManeuver = SCNAction.move(by: SCNVector3(xDelta, yDelta, zDelta), duration: maneuverDuration)
            self.inCurrentManeuver = true
            currentManeuver.timingMode = .easeInEaseOut
            self.runAction(currentManeuver, completionHandler: fullStop)

        }

        //FIRE TORPEDO LOGIC
        //if I'm not currently counting down to fire, start a new counter, with a random value between minShootInterval and maxShootInterval
        if cyclesUntilFireTorpedo  == 0 {
            self.fireTorpedo()
            cyclesUntilFireTorpedo = randRange(lower: Constants.minHumanShootInterval, upper: Constants.maxHumanShootInterval)
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
