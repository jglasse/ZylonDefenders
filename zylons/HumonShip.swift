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
	var currentSpeed = 0.0
	var shieldStrength = 100
	var weaponType = 0
	// orintation angles
	var theta = 0.0
	var phi = 0.0
	// current speed and target speed
	var speedVector =  vector3(0.0, 0.0, 0.0)
	var targetspeedVector = vector3(0.0, 0.0, 1.0)

	var zylonTargetPosition = vector3(10.0, 0.0, 0.0)

	var range = [Float]()

	func newTargetSpeedVector() {
	}

}
