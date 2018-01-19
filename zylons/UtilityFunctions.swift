//
//  UtilityFunctions.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 9/9/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let numberstrings = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

// MARK - Utility Functions
// These are globally available, and should be unit tested

func distanceFromZylonShip(x: Float, y: Float, z: Float) -> Float {
    let distance = sqrt(x*x + y*y + z*z)
    return distance
}

func computerBeepSound(_ soundString: String) {
    let soundURL = Bundle.main.url(forResource: soundString, withExtension: "mp3")
    let beepsound =  try! AVAudioPlayer(contentsOf: soundURL!)
    beepsound.volume = 0.5
    beepsound.play()
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
func randRange (lower: Float, upper: Float) -> Float {
    let difference = abs(upper - lower)
    return lower + Float(arc4random_uniform(UInt32(difference)))
}

// MARK - Extensions
// Extensions to game classes which are not part of their core functionality

extension ZylonGameViewController: CommandDelegate {

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
