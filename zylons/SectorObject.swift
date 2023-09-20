//
//  SectorObject.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 9/12/19.
//  Copyright © 2023 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class SectorObject: SCNNode {
    enum ObjectType {
        case humonShip
        case zylonStation
        case asteroid
    }
    var sectorObjectType: ObjectType =  .asteroid
}
