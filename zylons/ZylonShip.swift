//
//  ZylonShip.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/31/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

// Mark: - Damage enums
//enum ImpulseEngineDamage {
//    case noDamage
//    case plasmaManifoldFailure
//    case engineFailure
//}
//
//enum ComputerDamage {
//    case viralIntrusion
//    case targetingInoperative
//    case autoPilotInoperative
//    case shortRangeScannerInoperative
//    case longRangeScannerInoperative
//    case empathyCircuitFailure
//
//}

enum Quadrant: String {
    case alpha
    case beta
    case gama
    case delta
}

enum ShipDamage {
	case shieldGeneratorDestroyed
	case hullBreach
	case computerDamaged
	case shipDestroyed
}

struct ShipDisplay {
    var tactical = false
    var galacticMap = false
}

struct Sector {
    var quadrant: Quadrant = .alpha
	var y = 0
	var z = 0
}

class ZylonShip: SCNNode {
	var shieldsAreUp = false
	var currentSpeed = 0
	var currentSector = Sector()
    var display = ShipDisplay()
    var systemStatus = ShipSystems()
	var engineHealth = 100
	var shieldStrength = 100
	var energyStore = 10000
	var currentTorpedoBay = 1
    var sectorLocation = locationInSector(x: 500, y: 500, z: 500)
    var sector = currentSector(quadrant: .alpha, y: 30, z: 30)
    var damage = Damage()

    override init() {
        super.init()
        self.geometry = SCNSphere(radius: 0.20)
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
        var quadrant: Quadrant = .alpha
		var y = 0
		var z = 0

	}
	struct rotation {
		var theta = 0.0
		var phi = 0.0
	}

    enum DamageAmount: Int, CaseIterable {
        case functional = 0
        case damaged = 1
        case severelyDamaged = 2
        case destroyed = 3

        mutating func increase() {
            self = DamageAmount(rawValue: self.rawValue + 1) ?? .destroyed
        }
    }

    struct Damage {
        // core systems
        var outerHull = DamageAmount.functional
        var innerHull = DamageAmount.functional
        var shieldIntegrity = DamageAmount.functional
        var engineIntegrity = DamageAmount.functional

        // 
        var babelfishCircuit = DamageAmount.functional
        var genderIdentityCircuit = DamageAmount.functional
    }

	struct ShipSystems {
		var shieldStrength = 0
		var warpEnergy = 1000.0
        var shipDamage = Damage()
	}

	var range = [Float]()

    func takeDamage() {
        let dice = randIntRange(lower: 1, upper: 6)

//        switch dice {
//        case 1:
//            if self.damage.babelfishCircuit.rawValue < 3 { self.damage.babelfishCircuit = self.damage.babelfishCircuit.increase() }
//        case 2:
//            if self.damage.babelfishCircuit.rawValue < 3 { self.damage.genderIdentityCircuit.rawValue = self.damage.genderIdentityCircuit.rawValue + 1 }
//
//        default:
//            return
//        }
    }
    func updateSector() {
        self.currentSector.z+=1
    }
}
