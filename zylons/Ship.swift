//
//  Ship.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/31/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

struct Sector {
	var x = 0
	var y = 0
	var z = 0
}


class ZylonShip: SCNNode {
	var shields = false
	var currentSpeed = 0
	var currentSector = Sector()
	var engineHealth = 100
	var shieldStrength = 100
	var energyStore = 10000
	var currentTorpedoBay = 1
	
	// orintation angles
	var theta = 0.0
	var phi = 0.0
	
	
	var range = [Float]()
	
	
}
