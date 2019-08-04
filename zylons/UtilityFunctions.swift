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
import SceneKit
import GameController


// MARK - Utility Functions
// These are globally available, and should be unit tested

func distanceFromZylonShip(x: Float, y: Float, z: Float) -> Float {
    let distance = sqrt(x*x + y*y + z*z)
    return distance
}

func distanceBetweenPoints(first: SCNVector3, second: SCNVector3) -> Float {
    let xDistance: Float = first.x-second.x
    let yDistance: Float = first.y-second.y
    let zDistance: Float = first.z-second.z
    let sum = xDistance * xDistance + yDistance * yDistance + zDistance * zDistance
    let result = sqrt(sum)
    return result
}





func getSettings() -> GameSettings
{
    let defaults = UserDefaults.standard
    var gameSettings:GameSettings?
    let prologueBool = defaults.bool(forKey: "prologueViewed")
    gameSettings = GameSettings(prologueEnabled: prologueBool)
    if gameSettings != nil {
        print("gameSettings retreived from UserDefaults!")
        return gameSettings!
        
    }
    else
    {
        print("gameSettings NOT retreived from UserDefaults. CREATING!")
        save(settings: GameSettings(prologueEnabled: true))

        return GameSettings(prologueEnabled: true)}
    
}

func save(settings: GameSettings) {
    let defaults = UserDefaults.standard
    print("saving follwoing settings : \(settings.prologueEnabled)")
    
    defaults.set(settings.prologueEnabled, forKey: "prologueViewed")
}

extension ZylonGameViewController {

    func numberofShotsOnscreen() -> Int {
        var numberOfShots = 0
        mainGameScene.rootNode.enumerateChildNodes({ (child, _) in
            if (child.name == "torpedo") {  numberOfShots = numberOfShots+1}
        })

        return numberOfShots
    }

        // MARK: - MFI GAME CONTROLLER CODE

        private func processGameControllerInput() {
            guard let profile: GCExtendedGamepad = self.mainController?.extendedGamepad else {
                return
            }

            profile.valueChangedHandler = ({
                (gamepad: GCExtendedGamepad, element: GCControllerElement) in

                var position = CGPoint(x: 0, y: 0)
                var message: String = ""

                // left trigger
                if (gamepad.leftTrigger == element && gamepad.leftTrigger.isPressed) {
                    message = "Left Trigger - Shields"
                    self.toggleShields(UIButton())
                }

                // right trigger
                if (gamepad.rightTrigger == element && gamepad.rightTrigger.isPressed && !self.aButtonJustPressed) {
                    self.aButtonJustPressed = true
                    message = "Right Trigger - Fire"
                    self.fireTorp()
                }

                if (gamepad.rightTrigger == element && !gamepad.rightTrigger.isPressed) {
                    self.aButtonJustPressed = false
                    message = "Right Trigger - released"

                }

                // left shoulder button
                if (gamepad.leftShoulder == element && gamepad.leftShoulder.isPressed  && !self.leftShoulderJustPressed) {
                    self.leftShoulderJustPressed = true
                    self.toggleGalacticMap(self)
                }

                // Left Shoulder button UP
                if (gamepad.leftShoulder == element && !gamepad.leftShoulder.isPressed) {
                    self.leftShoulderJustPressed = false
                }

                // right shoulder button
                if (gamepad.rightShoulder == element && gamepad.rightShoulder.isPressed) {
                    message = "Right Shoulder Button"
                }

                // A button
                if (gamepad.buttonA == element && gamepad.buttonA.isPressed  && !self.aButtonJustPressed) {
                    message = "A Button - FIRE"
                    self.fireTorp()
                    self.aButtonJustPressed = true

                }
                // A button UP
                if (gamepad.buttonA == element && !gamepad.buttonA.isPressed) {
                    self.aButtonJustPressed = false
                    message = "A Button - FIRE"
                }

                // B button
                if (gamepad.buttonB == element && gamepad.buttonB.isPressed && !self.bButtonJustPressed) {
                    message = "B Button - toggleView"
                    self.bButtonJustPressed = true
                    self.toggleView(UIButton())
                }

                // B button UP
                if (gamepad.buttonB == element && !gamepad.buttonB.isPressed) {
                    self.bButtonJustPressed = false
                    message = "B Button - toggleView"
                }

                // X button
                if (gamepad.buttonX == element && gamepad.buttonX.isPressed) {
                    message = "X Button"
                }

                // Y button
                if (gamepad.buttonY == element && gamepad.buttonY.isPressed) {
                    message = "Y Button"
                }

                // d-pad
                if (gamepad.dpad == element) {
                    if (gamepad.dpad.up.isPressed) {
                        message = "D-Pad Up"
                    }
                    if (gamepad.dpad.down.isPressed) {
                        message = "D-Pad Down"
                    }
                    if (gamepad.dpad.left.isPressed) {
                        message = "D-Pad Left"
                    }
                    if (gamepad.dpad.right.isPressed) {
                        message = "D-Pad Right"
                    }
                }

                // left stick
                if (gamepad.leftThumbstick == element) {
                    if (gamepad.leftThumbstick.up.isPressed) {
                        message = "Left Stick %f \(gamepad.leftThumbstick.yAxis.value)"
                    }
                    if (gamepad.leftThumbstick.down.isPressed) {
                        message = "Left Stick %f \(gamepad.leftThumbstick.yAxis.value)"
                    }
                    if (gamepad.leftThumbstick.left.isPressed) {
                        message = "Left Stick %f \(gamepad.leftThumbstick.xAxis.value)"
                    }
                    if (gamepad.leftThumbstick.right.isPressed) {
                        message = "Left Stick %f \(gamepad.leftThumbstick.xAxis.value)"
                    }
                    position = CGPoint(x: CGFloat(gamepad.leftThumbstick.xAxis.value),
                                       y: CGFloat(gamepad.leftThumbstick.yAxis.value))
                    print("position: \(position)")
                }

                // right stick
                if (gamepad.rightThumbstick == element) {
                    if (gamepad.rightThumbstick.up.isPressed) {
                        message = "Right Stick %f \(gamepad.rightThumbstick.yAxis.value)"
                    }
                    if (gamepad.rightThumbstick.down.isPressed) {
                        message = "Right Stick %f \(gamepad.rightThumbstick.yAxis.value)"
                    }
                    if (gamepad.rightThumbstick.left.isPressed) {
                        message = "Right Stick %f \(gamepad.rightThumbstick.xAxis.value)"
                    }
                    if (gamepad.rightThumbstick.right.isPressed) {
                        message = "Right Stick %f \(gamepad.rightThumbstick.xAxis.value)"
                    }
                    //                position = CGPoint(x: gamepad.rightThumbstick.xAxis.value, y: gamepad.rightThumbstick.yAxis.value)
                    position = CGPoint(x: CGFloat(gamepad.rightThumbstick.xAxis.value),
                                       y: CGFloat(gamepad.rightThumbstick.yAxis.value))
                }

                print(message)
            }) as GCExtendedGamepadValueChangedHandler
        }

        @objc private func controllerWasConnected(_ notification: Notification) {
            let controller: GCController = notification.object as! GCController
            let status = "MFi Controller: \(String(describing: controller.vendorName)) is connected"
            print(status)
            self.joystickControl.isHidden = true

            mainController = controller
            processGameControllerInput()
        }

        @objc private func controllerWasDisconnected(_ notification: Notification) {
            let controller: GCController = notification.object as! GCController
            let status = "MFi Controller: \(String(describing: controller.vendorName)) is disconnected"
            print(status)

            mainController = nil
            self.joystickControl.isHidden = false

        }

    func overlayPos(node: SCNNode) -> CGPoint {
        let v1w =  node.convertPosition(node.boundingBox.min, to: self.scnView.scene?.rootNode)
        let v2w =  node.convertPosition(node.boundingBox.max, to: self.scnView.scene?.rootNode)

        //calc center of BB in world coordinates
        let center = SCNVector3Make(
            (v1w.x + v2w.x)/2,
            (v1w.y + v2w.y)/2,
            (v1w.z + v2w.z)/2)

        let screenPos3D = scnView.projectPoint(center)
        let screenPos2D = CGPoint(x: Double(screenPos3D.x), y: Double(screenPos3D.y))
        return screenPos2D

    }

    func rotate(_ node: SCNNode, around axis: SCNVector3, by angle: CGFloat) {
        let rotation = SCNMatrix4MakeRotation(Float(angle), axis.x, axis.y, axis.z)
        let newTransform = SCNMatrix4Mult(node.worldTransform, rotation)
        if let parent = node.parent {
            node.transform = parent.convertTransform(newTransform, from: nil)
        } else {
            node.transform = newTransform
        }
    }

}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

func randIntRange (lower: Int, upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
func randRange (lower: Float, upper: Float) -> Float {
    if upper > lower {
        let difference = abs(upper - lower)
        return lower + Float(arc4random_uniform(UInt32(difference)))
    } else {
        return lower
    }
}

// MARK: External Control

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
            enterSector(sectorNumber: 16)
        case "ATTACK":
            notYetImplemented(command)
        case "FORE":
            self.viewMode = .foreView
        case "AFT":
            self.viewMode = .aftView
        case "TAC":
            notYetImplemented(command)
        case "SHIELDS":
            toggleShields(UIButton())
        case "FIRE":
            fireTorpedo(UIButton())
        default:
            break

        }
}

    // MARK: Sound
    

    func playEngineSound(volume: Float) {
        var soundURL: URL?
        soundURL = Bundle.main.url(forResource: "ship_hum", withExtension: "mp3")
        try! engineSound = AVAudioPlayer(contentsOf: soundURL!)
        engineSound.numberOfLoops = -1
        engineSound.volume = volume
        engineSound.play()
    }

    func environmentSound(_ soundString: String) {
        let soundURL = Bundle.main.url(forResource: soundString, withExtension: "m4a")
        try! environmentSound = AVAudioPlayer(contentsOf: soundURL!)
        environmentSound.volume = 0.6
        environmentSound.play()
    }

    func finalExplosionSound() {
        let soundURL = Bundle.main.url(forResource: "death", withExtension: "mp3")
        try! environmentSound = AVAudioPlayer(contentsOf: soundURL!)
        environmentSound.volume = 0.6
        environmentSound.play()
        
    }
    func explosionSound() {
        let explosionArray = ["explosion", "explosion2", "explosion3", "explosion4"]
        let explosionString = explosionArray[randIntRange(lower: 0, upper: 3)]
        self.environmentSound(explosionString)
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

class GameHelper {
    
    static func rad2deg( rad:Float ) -> Float {
        return rad * (Float) (180.0 /  Double.pi)
    }
    
    static func deg2rad( deg:Float ) -> Float{
        return deg * (Float)(Double.pi / 180)
    }
    
    static func getPanDirection(velocity: CGPoint) -> String {
        var panDirection:String = ""
        if ( velocity.x > 0 && velocity.x > abs(velocity.y) || velocity.x < 0 && abs(velocity.x) > abs(velocity.y) ){
            panDirection = "horizontal"
        }
        
        if ( velocity.y < 0 && abs(velocity.y) > abs(velocity.x) || velocity.y > 0 &&  velocity.y  > abs(velocity.x)) {
            panDirection = "vertical"
        }
        
        
        return panDirection
    }
    
}




