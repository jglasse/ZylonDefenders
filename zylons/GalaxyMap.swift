//
//  GalaxyMap.swift
//  Zylon Defenders
//
//  Created by jglasse on 5/31/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation

struct NewGalaxyMap {
    struct Sector {
        var designation = ""
        var sectorObjects =  [SectorObject]()
    }
    struct Quadrant {
        var designation: KnownQuadrants
        var min: Int
        var max: Int

        init(designation: KnownQuadrants, min: Int, max: Int) {
            self.designation = designation
            self.max = max
            self.min = min
        }
    }

    var map =  [Sector]()
    var alphaQuadrant =  Quadrant(designation: .alpha, min: 0, max: 31)
    var betaQuadrant = Quadrant(designation: .beta, min: 32, max: 63)
    var gammaQuadrant = Quadrant(designation: .gamma, min: 64, max: 95)
    var deltaquadrant = Quadrant(designation: .delta, min: 96, max: 127)

     init(difficulty: Int) {
        var numberofOccupiedSectors = 0
        var maxShipsPerSector = 0
        switch difficulty {
        case 1:
            numberofOccupiedSectors = 6
            maxShipsPerSector = 3
        case 2:
            numberofOccupiedSectors = 8
            maxShipsPerSector = 3
        case 3:
            numberofOccupiedSectors = 10
            maxShipsPerSector = 4
        case 4:
            numberofOccupiedSectors = 12
            maxShipsPerSector = 4
        default:
            numberofOccupiedSectors = 6
            maxShipsPerSector = 3
        }

        // first, add an empty map
        for x in 1...128 {
            let sectorname = String(x)
            let currentSector = Sector(designation: sectorname, sectorObjects: [HumonShip]())
            self.map.append(currentSector)
        }
        //then add spaceStations to three sectors
        
        for _ in 1...3 {
            let 
            
        }
        
        
        
        // then, iterate over the number of occupied sectors...
        for _ in 1...numberofOccupiedSectors {
            // picking a random sector:
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            let numberofshipsToAdd = Int(randIntRange(lower: 1, upper: maxShipsPerSector))
            var shipsArray = [HumonShip]()
            // and generating sector ships (up to the max number)
            for _ in 1...numberofshipsToAdd {
                shipsArray.append(HumonShip())
            }
            // and assigning those ships to that random sector
            self.map[currentSectorIndex].sectorObjects = shipsArray
            }
        }
    }

struct GalaxyMap {
    var alphaSector = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var betaSector = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var gammaSector = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var deltaSector = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var entireMap: [[Int]] {
        return [alphaSector, betaSector, gammaSector, deltaSector]
    }

    // convenience init to randomly assign X number of ships
    init(withRandomlyPlacedShips numberOfOccupiedSectors: Int, maxNumberPerSector: UInt32) {
        for _ in 1...Int(numberOfOccupiedSectors) {
            let numberOfZylons = Int(arc4random_uniform(_:maxNumberPerSector) + 1)
            let sector = Int(arc4random_uniform(_:3) + 1)
            let sectorIndex = Int(arc4random_uniform(_:31))

            switch sector {
            case 1:
                alphaSector[sectorIndex] = numberOfZylons
            case 2:
                betaSector[sectorIndex] = numberOfZylons
            case 3:
                gammaSector[sectorIndex] = numberOfZylons
            case 4:
                deltaSector[sectorIndex] = numberOfZylons
            default:

                return
            }
        }

    }
}
