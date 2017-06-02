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

struct galaxyMap {

}
class Ship: SCNNode {
	
	var currentSector = Sector()
	var engineHealth = 100
	var shieldStrength = 100
	var energyStore = 10000
	var shieldsUp = false
	var currentTorpedoBay = 1
}
