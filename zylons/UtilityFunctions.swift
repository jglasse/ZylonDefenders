//
//  UtilityFunctions.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 9/9/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import Foundation
import UIKit


let numberstrings:[String] = ["zero", "one", "two", "three","four","five","six","seven","eight","nine"]


// MARK - Utility Functions
// These are globally available, and should be unit tested

func distanceInSpace(x:Float, y: Float, z:Float) -> Float{
    let distance = sqrt(x*x + y*y + z*z)
    return distance
}

func randRange (lower: Float , upper: Float) -> Float {
    return lower + Float(arc4random_uniform(UInt32(upper - lower + 1)))
}

// MARK - Extensions
// Extensions to game classes which are not part of their core functionality

extension GameViewController: CommandDelegate {
    
    // receive commands from iOS remote controller
    func execute(command: String) {
        print ("Executing remote command: \(command)")
        switch command {
            
        case "Speed 9":
            setSpeed(9)
        case "Speed 8":
            setSpeed(8)
        case "Speed 7":
            setSpeed(7)
        case "Speed 6":
            setSpeed(6)
        case "Speed 5":
            setSpeed(5)
        case "Speed 4":
            setSpeed(4)
        case "Speed 3":
            setSpeed(3)
        case "Speed 2":
            setSpeed(2)
        case "Speed 1":
            setSpeed(1)
            
        case "Speed 0":
            setSpeed(0)
        case "ABORT":
            notYetImplemented(command)
        case "GRID":
            enterSector()
        case "ATTACK":
            notYetImplemented(command)
        case "FORE":
            foreView()
        case "AFT":
            aftView()
        case "TAC":
            notYetImplemented(command)
        case "SHIELDS":
            toggleShields()
        case "TAC":
            notYetImplemented(command)
            
        case "FIRE":
            fireTorpedo(UIButton())
        default:
            break
            
        }
}
}
