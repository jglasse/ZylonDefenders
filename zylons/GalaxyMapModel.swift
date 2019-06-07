//
//  GalaxyMap.swift
//  Zylon Defenders
//
//  Created by jglasse on 5/31/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation

struct GalaxyMapModel {
    var map =  [Sector]()

    mutating func decrementEnemyCount(sector: Int){
        print("decrementing enemy count from \(self.map[sector].numberOfSectorObjects)")
        self.map[sector].numberOfSectorObjects -= 1
        if  self.map[sector].numberOfSectorObjects == 0 {
            self.map[sector].sectorType = .empty
        }
        
    }
     init(difficulty: Int) {
        var numberofOccupiedSectors = 0
        var maxShipsPerSector = 0
        var numberofStations = 0
        
        // based on difficulty level, set internal variables
        switch difficulty {
        case 1:
            numberofOccupiedSectors = 12
            maxShipsPerSector = 3
            numberofStations = 4

        case 2:
            numberofOccupiedSectors = 15
            maxShipsPerSector = 3
            numberofStations = 4

        case 3:
            numberofOccupiedSectors = 18
            maxShipsPerSector = 4
            numberofStations = 4

        case 4:
            numberofOccupiedSectors = 25
            maxShipsPerSector = 5
            numberofStations = 4

        default:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 3
            numberofStations = 4

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
                print("Adding \(numberofshipsToAdd) enemies to sector \(currentSectorIndex)")

                }
            }
        }
    }
