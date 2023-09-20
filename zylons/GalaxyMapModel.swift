//
//  GalaxyMap.swift
//  Zylon Defenders
//
//  Created by jglasse on 5/31/18.
//  Copyright © 2023 Jeffery Glasse. All rights reserved.
//

import Foundation

struct GalaxyMapModel {
    var map =  [SectorGrid]()
    var surroundedStationIndexes = [Int]()
    var kh = Kohai()
    var updateInterval: Int
    var timeSinceLastUpdate: Int
    var initialNumberofOccupiedSectors = 0
    var currentNumberOfOccupiedSectors: Int { let numberOfOccupiedSectors = map.filter({$0.sectorType == SectorGridType.enemy || $0.sectorType == SectorGridType.enemy2 || $0.sectorType == SectorGridType.enemy3}).count
        devLog("numberOfOccupiedSectors: \(numberOfOccupiedSectors)")
        return numberOfOccupiedSectors}
    var occupiedSectorRatio: Float {
        devLog("initialNumberofOccupiedSectors: \(initialNumberofOccupiedSectors)")
        devLog("currentNumberOfOccupiedSectors: \(currentNumberOfOccupiedSectors)")
        print("occupiedSectorRatio:", Float(Float(currentNumberOfOccupiedSectors)/Float(initialNumberofOccupiedSectors)))

        return Float(Float(currentNumberOfOccupiedSectors)/Float(initialNumberofOccupiedSectors))}

    mutating func decrementEnemyCount(sector: Int) {
        devLog("decrementing enemy count from \(self.map[sector].numberOfSectorObjects)")
        devLog("current sector Type: \(self.map[sector].sectorType)")
        self.map[sector].numberOfSectorObjects -= 1
        if  self.map[sector].numberOfSectorObjects == 0 {
            self.map[sector].sectorType = .empty
            kh.computerBeepSound("enemyAlert")
        }

    }
    mutating func updateHumonTroopMovements() {
        timeSinceLastUpdate+=1
        if timeSinceLastUpdate >= updateInterval {
            devLog("Updating Humon Troop Movements")
            // find each space station, check if it is surrounded
            // if it is, begin a timer (
            timeSinceLastUpdate = 0
        }
     }
     init(difficulty: Int) {
         devLog("creating map with difficulty \(difficulty)")
        var numberofOccupiedSectors = 0
        var maxShipsPerSector = 0
        var numberofStations = 0
         self.timeSinceLastUpdate = 0
         self.updateInterval = 4800 / difficulty
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

        case 5:
            numberofOccupiedSectors = 40
            maxShipsPerSector = 7
            numberofStations = 4

        default:
            numberofOccupiedSectors = 30
            maxShipsPerSector = 3
            numberofStations = 4

        }
        initialNumberofOccupiedSectors = numberofOccupiedSectors

        // first, add an empty map with 128 sectors
        for x in 1...128 {
            let currentSector = SectorGrid(number: x, enemyTypes: nil, numberOfSectorObjects: 0, sectorType: .empty)
            self.map.append(currentSector)
        }
        // then randomly add Space Stations, evenly distributed acrozss four sectors
        // NOTE - current algorithm assumes 4 stations
        for x in 0...numberofStations-1 {
            let lowerrange: Int = x*32
            let currentSectorIndex = randIntRange(lower: lowerrange, upper: lowerrange+31)
            self.map[currentSectorIndex].numberOfSectorObjects = 1
            self.map[currentSectorIndex].sectorType = .starbase
        }

        // then, iterate over the number of occupied sectors...

        for _ in 1...numberofOccupiedSectors {
        // picking a random sector
            let currentSectorIndex = Int(randRange(lower: 0, upper: 127))
            if self.map[currentSectorIndex].sectorType != .starbase {

                let numberofshipsToAdd = Int(randIntRange(lower: 1, upper: maxShipsPerSector))
        // and assigning those ships to that random sector
                self.map[currentSectorIndex].numberOfSectorObjects = numberofshipsToAdd
                self.map[currentSectorIndex].enemyTypes = [ShipType]()
                let typeOfSectorRoll = randIntRange(lower: 1, upper: 3)
                var chanceOfFighters = 0
                switch typeOfSectorRoll {
                case 3:
                    self.map[currentSectorIndex].sectorType = .enemy3
                     chanceOfFighters = 2
                case 2:
                    self.map[currentSectorIndex].sectorType = .enemy2
                     chanceOfFighters = 1
                default:
                    self.map[currentSectorIndex].sectorType = .enemy
                }
                for _ in 1...numberofshipsToAdd {
                    let randType = randIntRange(lower: 0, upper: chanceOfFighters)
                    let shiptype = ShipType(rawValue: Int(randType)) ?? ShipType.scout
                    self.map[currentSectorIndex].enemyTypes?.append(shiptype)
                }

                }
            }
        }
    }
