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

enum KnownQuadrants: String {
    case alpha,beta,gamma,delta
}



class ZylonShip: SectorObject {
    var shipClock = 0
    var currentSectorNumber = 64
    var targetSectorNumber = 68
    var tacticalDisplayEngaged = false
    var isInAlertMode = false
    var isCurrentlyinWarp = false
	var shieldsAreUp = false
	var currentSpeed = 0
    var systemStatus = ShipSystems()
	var engineHealth = 100
	var shieldStrength = 100
	var energyStore = 10000
	var currentTorpedoBay = 1
    var sectorLocation = locationInSector(x: 500, y: 500, z: 500)
    var shipSystems = ShipsSystems()
    
    let statusMessages = ["functional", "damaged", "severely damaged", "destroyed"]

    override init() {
        super.init()
        self.geometry = SCNSphere(radius: 0.20)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	struct locationInSector {
		var x = 0
		var y = 0
		var z = 0
	}


	struct rotation {
		var theta = 0.0
		var phi = 0.0
	}

    enum DamageAmount: Int {
        case functional
        case damaged
        case severelyDamaged
        case destroyed

        mutating func increase() {
            self = DamageAmount(rawValue: self.rawValue + 1) ?? .destroyed
        }
    }

    struct ShipsSystems {
        // core systems
        var outerHull = DamageAmount.functional
        var innerHull = DamageAmount.functional
        var shieldIntegrity = DamageAmount.functional
        var engineIntegrity = DamageAmount.functional

        // comedic systems
        var babelfishCircuit = DamageAmount.functional
        var genderIdentityCircuit = DamageAmount.functional
    }

	struct ShipSystems {
		var shieldStrength = 0
		var warpEnergy = 1000.0
        var shipDamage = ShipsSystems()
	}

	var range = [Float]()
    
    func updateShipClock() {
        print("updateShipClock")
        self.shipClock += 1
        
        if self.shipClock % 60 == 0
        {
        if self.energyStore>1 {
            self.energyStore -= 1
        }
            
        }
        
    }
    
    func drainEnergyStore() {
        print("depleteEnergyStore")
        if self.energyStore>1 {
            self.energyStore -= 1
        }
    }
    
    func takeDamage() {

        // if shields at zero strength and they are up when hit, they are immediately destroyed

        if shieldStrength <= 0 && shieldsAreUp {
            shipSystems.shieldIntegrity = .destroyed
            shieldsAreUp = false
        }
       // print("OUTER HULL HIT! Ship Damage: \(shipSystems)")
        print("OUTER HULL HIT! Ship Damage")

        // calculateShipDamage
        //        let dice = randIntRange(lower: 1, upper: 6)
        //
        //        switch dice {
        //        case 1:
        //            if self.shipSystems.babelfishCircuit.rawValue < 3 { self.shipSystems.babelfishCircuit = DamageAmount(rawValue: self.shipSystems.babelfishCircuit+1)  }
        //        case 2:
        //            if self.shipSystems.genderIdentityCircuit.rawValue < 3 { self.shipSystems.genderIdentityCircuit = self.shipSystems.genderIdentityCircuit.rawValue + 1 }
        //
        //        default:
        //            return
        //        }

    }
    
    
}
