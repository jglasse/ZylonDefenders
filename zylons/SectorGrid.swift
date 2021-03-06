//
//  Sector.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/27/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation

enum SectorGridType: Int, Codable {
    case enemy
    case enemy2
    case enemy3
    case starbase
    case empty
}

struct SectorGrid: Codable {
    var number: Int
    var enemyTypes = [ShipType]()
    var numberOfSectorObjects =  0
    var sectorType = SectorGridType.empty
}

extension SectorGrid {
    var numberString: String {
         return String(number)
     }
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
         case 33...64:
             return number - 32
         case 65...96:
             return number - 64
         default:
             return number
         }
     }

}
