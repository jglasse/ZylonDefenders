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
        var number = ""
        var sectorObjects =  0
        var sectorType = SectorType.empty
    }
    enum SectorType {
        case enemy
        case starbase
        case empty
    }

    var map =  [Sector]()

     init(difficulty: Int) {
        var numberofOccupiedSectors = 0
        var maxShipsPerSector = 0
        var numberofStations = 0
        
        // based on difficulty level, set internal variables
        switch difficulty {
        case 1:
            numberofOccupiedSectors = 6
            maxShipsPerSector = 3
            numberofStations = 3

        case 2:
            numberofOccupiedSectors = 8
            maxShipsPerSector = 3
            numberofStations = 3

        case 3:
            numberofOccupiedSectors = 10
            maxShipsPerSector = 4
            numberofStations = 3

        case 4:
            numberofOccupiedSectors = 12
            maxShipsPerSector = 5
            numberofStations = 3

        default:
            numberofOccupiedSectors = 6
            maxShipsPerSector = 3
            numberofStations = 3

        }

        // first, add an empty map with 128 sectors
        for x in 1...128 {
            let sectorname = String(x)
            let currentSector = Sector(number: sectorname, sectorObjects: 0, sectorType: .empty)
            self.map.append(currentSector)
        }
        //then randomly add space Stations to the appropriate number of sectors
        for _ in 1...numberofStations {
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            self.map[currentSectorIndex].sectorObjects = 1
            self.map[currentSectorIndex].sectorType = .starbase
        }

        // then, iterate over the number of occupied sectors...
        for _ in 1...numberofOccupiedSectors {
            // picking a random sector:
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            if self.map[currentSectorIndex].sectorType != .starbase {
                let numberofshipsToAdd = Int(randIntRange(lower: 1, upper: maxShipsPerSector))
            // and assigning those ships to that random sector
                self.map[currentSectorIndex].sectorObjects = numberofshipsToAdd
                self.map[currentSectorIndex].sectorType = .enemy
                }
            }
        }
    }
