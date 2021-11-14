//
//  Constants.swift
//  Zylon Defenders
//
//  Created by jglasse on 2/12/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

let numberstrings = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

struct Constants {
    static let fadedMapTransparency: CGFloat = 0.03
    static let starMoveDivider: Float = 0.4
    static let maxTorpedoes = 6
    static let maxEnemyShips = 5
    static let torpedoLifespan = 140
    static let torpedoSpeed = 0.6
    static let torpedoCorrectionSpeedDivider: Float = 13
    static let shotDelay = 1
    static let thrustAmount: Float = 5.0
    static let numberOfStars = 100
    static let xAxis = SCNVector3Make(1, 0, 0)
    static let yAxis = SCNVector3Make(0, 1, 0)
    static let zAxis = SCNVector3Make(0, 0, 1)
    static let starBoundsX = 200
    static let starBoundsY = 500
    static let starBoundsZ = 500
    static let cameraFalloff = 1500.0
    static let minHumanShootInterval: Float = 185
    static let maxHumanShootInterval: Float = 800
    static let sectorBreadth = 500
    static let galacticMapBlipRadius: CGFloat = 0.06
}

struct ObjectCategories {
    static let zylonShip = 0b00000001
    static let zylonFire = 0b00000010
    static let enemyShip = 0b00000100
    static let enemyFire = 0b00001000
    static let starBases = 0b00010000
    static let asteroids = 0b00100000
    static let warpgrids = 0b01000000
}
