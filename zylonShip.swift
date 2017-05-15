//
//  zylonShip.swift
//  
//
//  Created by Jeff Glasse on 5/15/17.
//
//

import Foundation
import UIKit
import SceneKit


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

enum shipDamage {
    case noDamage
    case shieldGeneratorDestroyed
    case hullBreach
    case shipDesroyed
}






class zylonShip: SCNNode {
    static var sharedInstance = Ship()
    
    struct locationInSector{
        var x = 0
        var y = 0
        var z = 0
    }
    struct currentSector{
        var sectorX = 0
        var sectorY = 0
        var sectorZ = 0
        
    }
    struct rotation{
        var xRot = 0.0
        var yRot = 0.0
        var zRot = 0.0
    }
    struct shipSystems {
        var shieldStrength = 0
        var warpEnergy = 100.0
        var shipDamageStack: [shipDamage] = [.noDamage]
        var compDamageStack = 0
        var engineDamageStack: [ImpulseEngineDamage] = [.noDamage]
        
    }
    
}
