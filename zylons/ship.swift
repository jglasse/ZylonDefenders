//
//  ship.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/3/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit


class ship: SCNNode {
    static var sharedInstance = ship()

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
        var xRot = 0
        var yRot = 0
        var zRot = 0
    }
    struct shipSystems {
        var shieldStrength = 0
        var warpEnergy = 100.0
    
    
    }

}
