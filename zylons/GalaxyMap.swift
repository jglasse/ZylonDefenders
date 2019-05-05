//
//  GalaxyMap.swift
//  Zylon Defenders
//
//  Created by jglasse on 5/31/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation

struct NewGalaxyMap {

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
