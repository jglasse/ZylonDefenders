//
//  GalaxyMap.swift
//  Zylon Defenders
//
//  Created by jglasse on 5/31/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation

enum SectorType {
    case enemy
    case starbase
    case empty
}
struct Sector {
    var number = 0
    var numberString: String {
        return String(number)
    }

    var numberOfSectorObjects =  0
    var sectorType = SectorType.empty
    var quadrant: KnownQuadrants {
        switch number
        {
        case 1...32:
            return .alpha
        case 33...64:
            return .beta
        case 65...96:
            return .gamma
        default:
            return .delta
        }
    }
    
    var quadrantNumber: Int {
        switch number
        {
        case 97...128:
            return number - 96
        case 33...64:
            return number - 32
        case 65...96:
            return number - 64
        default:
            return number
        }
    }
}


struct NewGalaxyMap {
    var map =  [Sector]()

     init(difficulty: Int) {
        var numberofOccupiedSectors = 0
        var maxShipsPerSector = 0
        var numberofStations = 0
        
        // based on difficulty level, set internal variables
        switch difficulty {
        case 1:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 3
            numberofStations = 15

        case 2:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 3
            numberofStations = 15

        case 3:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 4
            numberofStations = 15

        case 4:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 5
            numberofStations = 15

        default:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 3
            numberofStations = 15

        }

        // first, add an empty map with 128 sectors
        for x in 1...128 {
            let currentSector = Sector(number: x, numberOfSectorObjects: 0, sectorType: .empty)
            self.map.append(currentSector)
        }
        //then randomly add space Stations to the appropriate number of sectors
        for _ in 1...numberofStations {
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            self.map[currentSectorIndex].numberOfSectorObjects = 1
            self.map[currentSectorIndex].sectorType = .starbase
        }

        // then, iterate over the number of occupied sectors...
        print("Adding \(numberofOccupiedSectors) occipied Sectors")
        for _ in 1...numberofOccupiedSectors {
            // picking a random sector:
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            if self.map[currentSectorIndex].sectorType != .starbase {
                
                let numberofshipsToAdd = Int(randIntRange(lower: 1, upper: maxShipsPerSector))
            // and assigning those ships to that random sector
                self.map[currentSectorIndex].numberOfSectorObjects = numberofshipsToAdd
                self.map[currentSectorIndex].sectorType = .enemy
                print("Adding \(numberofshipsToAdd) to sector \(currentSectorIndex)")

                }
            }
        }
    }
