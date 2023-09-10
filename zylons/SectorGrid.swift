//
//  Sector.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/27/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation

enum SectorGridType {
    case enemy, enemy2, enemy3, starbase, empty
}

enum KnownQuadrants: String {
    case alpha, beta, gamma, delta
}

struct SectorGrid {
    var number = 0
    var numberString: String {
        return String(number)
    }
    var enemyTypes: [ShipType]?
    var numberOfSectorObjects =  0
    var sectorType = SectorGridType.empty
    var quadrant: KnownQuadrants {
        switch number {
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
        switch number {
        case 97...128:
            return number - 96
        case 65...96:
            return number - 64
        case 33...64:
            return number - 32
        default:
            return number
        }
    }
}
