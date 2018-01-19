//
//  ZylonShip.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/31/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

enum ShipStickPosition {
    case up
    case down
    case left
    case right
    case zeroed
}

enum ImpulseEngineDamage {
	case noDamage
	case plasmaManifoldFailure
	case engineFailure
}

enum WarpGridDamage {
	case noDamage
	case autoPilotDestroyed
	case governorFailure
	case gridCoreFailureImminent
}

enum ComputerDamage {
	case viralIntrusion
	case targetingInoperative
	case autoPilotInoperative
	case shortRangeScannerInoperative
	case longRangeScannerInoperative
    case empathyCircuitFailure

}
enum ShipDamage {
	case shieldGeneratorDestroyed
	case hullBreach
	case computerDamaged
	case shipDestroyed

}

struct Sector {
	var x = 0
	var y = 0
	var z = 0
}

class ZylonShip: SCNNode {
	var shields = false
	var currentSpeed = 0
	var currentSector = Sector()
    var enemyShipsInSector = 0
	var engineHealth = 100
	var shieldStrength = 100
	var energyStore = 10000
	var currentTorpedoBay = 1
    var sectorLocation = locationInSector(x: 500, y: 500, z: 500)
    var sector = currentSector(sectorX: 30, sectorY: 30, sectorZ: 30)
    override init() {
        super.init()
        self.geometry = SCNSphere(radius: 0.25)
      //  self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	struct locationInSector {
		var x = 0
		var y = 0
		var z = 0
	}

	struct currentSector {
		var sectorX = 0
		var sectorY = 0
		var sectorZ = 0

	}
	struct rotation {
		var theta = 0.0
		var phi = 0.0
	}

	struct shipSystems {
		var shieldStrength = 0
		var warpEnergy = 100.0
		var shipDamageStack = [ShipDamage]()
		var compDamageStack = [ComputerDamage]()
		var engineDamageStack: [ImpulseEngineDamage] = [.noDamage]

	}

	var range = [Float]()

    func updateSector() {
        self.currentSector.z+=1
    }
}
