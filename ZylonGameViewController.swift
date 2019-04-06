//
//  ZylonGameViewController.swift
//  Zylon Defenders
//
//  Created by Jeffery Glasse on 11/6/16.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit
import AVFoundation
//import CoreMotion
import MultipeerConnectivity
import GameController

class ZylonGameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    // MARK: - Multipeer
    var myMCController = MCController.sharedInstance

    // MARK: - Mfi Game Controller vars
    var mainController: GCController?
    var aButtonJustPressed = false
    var bButtonJustPressed = false
    var leftTriggerJustPressed = false
    var rightTriggerJustPressed = false
    var rightShoulderJustPressed = false
    var leftShoulderJustPressed = false

    // MARK: - Scenes, Views and Nodes
    var mainGameScene = SCNScene()
    var scnView: SCNView!
    let sectorObjectsNode = SCNNode()

    let galacticMap = SCNScene(named: "art.scnassets/galacticmap.dae")

    var forwardCameraNode = SCNNode()
    var rearCameraNode = SCNNode()
    var sectorScanCameraNode = SCNNode()
    let warpGrid = SCNNode()

    var currentExplosionParticleSystem: SCNParticleSystem?
	var starSprites = [SCNNode]() // array of stars to make updating them each frame easy

   // var enemyDrone: SCNNode?  // this should be removed in favor of enemyShipsInSector

    struct GalaxyMap {
        var sectorA = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var sectorB = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var sectorC = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var sectorD = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var entireMap: [[Int]] {
            return [sectorA, sectorB, sectorC, sectorD]
        }

        // convenience init to randomly assign X number of ships
        init(withRandomlyPlacedShips numberOfOccupiedSectors: Int, maxNumberPerSector: UInt32) {
            for _ in 1...Int(numberOfOccupiedSectors) {
                let numberOfZylons = Int(arc4random_uniform(_:maxNumberPerSector) + 1)
                let sector = Int(arc4random_uniform(_:3) + 1)
                let sectorIndex = Int(arc4random_uniform(_:31))

                switch sector {
                case 1:
                    sectorA[sectorIndex] = numberOfZylons
                case 2:
                    sectorB[sectorIndex] = numberOfZylons
                case 3:
                    sectorC[sectorIndex] = numberOfZylons
                case 4:
                    sectorD[sectorIndex] = numberOfZylons
                default:

                    return
                }
            }

        }
    }

    var zylonFleet = GalaxyMap(withRandomlyPlacedShips: 20, maxNumberPerSector: 3)
    var enemyShipsInSector = [HumonShip]()
    var enemyShipCountInSector: Int {
        return enemyShipsInSector.count
    }

    var ship = ZylonShip()
    var zylonShields = SCNNode()

	var shipHud: HUD!

    var zylonScanner = Scanner()

    let divider: Float = 100.0
    var xThrust: Float { return Float(cos(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}
    var yThrust: Float { return Float(sin(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}

    // Sounds
    var engineSound: AVAudioPlayer!
	var warpEngineSound: AVQueuePlayer!
    var shieldSound: AVAudioPlayer!
    var photonSound1: AVAudioPlayer!
    var photonSound2: AVAudioPlayer!
    var photonSound3: AVAudioPlayer!
    var photonSound4: AVAudioPlayer!
    var beepsound: AVAudioPlayer!
    var computerVoice: AVQueuePlayer!
    var environmentSound: AVAudioPlayer!
	var explosionDuration = 0

    //var motionManager: CMMotionManager!

    // Misc Variables
    var currentPhoton = 0
    var numberOfZylonShotsOnscreen = 0
    var numberOfHumanShotsOnscreen = 0

    // MARK: - IBOutlets

    @IBOutlet weak var joystickControl: JoyStickView!
    @IBOutlet weak var tacticalDisplay: UIView!
	@IBOutlet weak var currentSpeedDisplay: UILabel!
	@IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var phiDisplay: UILabel!
    @IBOutlet weak var thetaDisplay: UILabel!
    @IBOutlet weak var enemiesInSectorDisplay: UILabel!
    @IBOutlet weak var targetDistanceDisplay: UILabel!
    @IBOutlet weak var shieldsDisplay: UILabel!
    @IBOutlet weak var shieldStrengthDisplay: UILabel!

    // MARK: - IBActions

    @IBAction func toggleGalacticMap(_ sender: Any) {
        computerBeepSound("beep")
        let transition = SKTransition.fade(withDuration: 0.15)
        if scnView.scene  == galacticMap {
            scnView.present(mainGameScene, with: transition, incomingPointOfView: mainGameScene.rootNode.childNode(withName: "camera", recursively: true), completionHandler: {
                self.scnView.allowsCameraControl = false
            })

        } else {
            scnView.present(galacticMap!, with: transition, incomingPointOfView: galacticMap?.rootNode.childNode(withName: "camera", recursively: true), completionHandler: {
                self.scnView.allowsCameraControl = false
            })

        }

    }

    @IBAction func toggleTacticalDispplay(_ sender: Any) {
        tacticalDisplay.isHidden = !tacticalDisplay.isHidden
        zylonScanner.isHidden = tacticalDisplay.isHidden

    }

    @IBAction func toggleView(_ sender: UIButton) {
		SCNTransaction.animationDuration = 0.0

		if scnView.pointOfView == forwardCameraNode {
			sender.setTitle("AFT", for: .normal)
            aftView()
        } else {
			sender.setTitle("FORE", for: .normal)
            foreView()
        }
        computerBeepSound("beep")
		SCNTransaction.animationDuration = 0.0

    }

    func computerBeepSound(_ soundString: String) {
        if let soundURL = Bundle.main.url(forResource: soundString, withExtension: "mp3") { do {
            try beepsound =  AVAudioPlayer(contentsOf: soundURL)
            } catch {
            print("beepsound failed")
            }
        beepsound.volume = 0.5
        beepsound.play()
        }
    }

    func envSound(_ soundString: String) {
        let soundURL = Bundle.main.url(forResource: soundString, withExtension: "m4a")
        beepsound =  try! AVAudioPlayer(contentsOf: soundURL!)
        beepsound.volume = 0.5
        beepsound.play()
    }
    func fireHumonTorpedo(fromShip: HumonShip) {
        let torpedoNode = Torpedo(designatedTorpType: .humon)
        sectorObjectsNode.addChildNode(torpedoNode)
      //  let driftAmount: Float = 2
      //  let forceAmount: Float = 195
            torpedoNode.worldPosition = fromShip.worldPosition
            //torpedoNode.physicsBody?.applyForce(SCNVector3Make(-driftAmount, 1.7, forceAmount), asImpulse: true)
    }

    fileprivate func fireTorp() {
        if numberOfZylonShotsOnscreen < Constants.maxTorpedoes && !self.aButtonJustPressed {
            let torpedoNode = Torpedo(designatedTorpType: .zylon)
            let photonSoundArray = [photonSound1, photonSound2, photonSound3, photonSound4]
            let currentplayer = photonSoundArray[currentPhoton]

            mainGameScene.rootNode.addChildNode(torpedoNode)
            let driftAmount: Float = 2
            let offset: Float = 4
            let forceAmount: Float = -95
            if ship.currentTorpedoBay == 1 {
                ship.currentTorpedoBay = 2
                torpedoNode.position = SCNVector3Make(offset, -2, 0)
                torpedoNode.physicsBody?.applyForce(SCNVector3Make(-driftAmount, 1.7, forceAmount), asImpulse: true)
            } else {
                ship.currentTorpedoBay = 1

                torpedoNode.position = SCNVector3Make(-offset, -2, 0)
                torpedoNode.physicsBody?.applyForce(SCNVector3Make(driftAmount, 1.7, forceAmount), asImpulse: true)

            }
            currentplayer?.play()
            currentPhoton = currentPhoton+1
            if currentPhoton>(photonSoundArray.count - 1) {currentPhoton = 0}
          //countNodes()
        } else {
            computerBeepSound("torpedo_fail")
        }
}

@IBAction func fireTorpedo(_ sender: UIButton) {
fireTorp()
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

    @IBAction func spawnDrone(_ sender: UIButton) {
        spawnDrone()
    }

    func spawnDrone() {
        let enemyDrone = HumonShip()
        let constraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
        constraint.isGimbalLockEnabled = true
        enemyDrone.constraints = [constraint]
        enemyDrone.position = self.mainGameScene.rootNode.convertPosition((enemyDrone.worldPosition), to: self.sectorObjectsNode)
        self.sectorObjectsNode.addChildNode(enemyDrone)
    }

    func spawnDrones(number: Int) {
        for _ in 1...number {
            spawnDrone()
        }
    }

	@IBOutlet weak var stepperSpeed: UIStepper!

	@IBAction func gridWarp(_ sender: UIButton) {
        performWarp()
		let deadlineTime = DispatchTime.now() + .seconds(6)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.enterSector()
			self.setSpeed(3)
            self.forwardCameraNode.camera?.motionBlurIntensity = 0

		}
        let spawnDeadline = DispatchTime.now() + .seconds(8)
        DispatchQueue.main.asyncAfter(deadline: spawnDeadline) {
           // self.warpGrid.removeFromParentNode()
            self.spawnDrones(number: Int(randRange(lower: 2, upper: 6)))
        }

    }

    @IBAction func speedChanged(_ sender: UIStepper) {
        computerBeepSound("beep")
        let targetSpeed = sender.value
        setSpeed(Int(targetSpeed))
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

    // MARK: - SETUP

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.zylonFleet)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.controllerWasConnected),
                                               name: NSNotification.Name.GCControllerDidConnect,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.controllerWasDisconnected),
                                               name: NSNotification.Name.GCControllerDidDisconnect,
                                               object: nil)
        setupView()
        setupScene()
        setupShip()
        spawnDrones(number: 3)
       // myMCController.setup()
       // myMCController.myCommandDelegate = self
        shipHud.parentScene = self
    }

    func setupView() {
        scnView = self.view as? SCNView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        scnView.backgroundColor = UIColor.black
        joystickControl.movable = false
        joystickControl.baseAlpha = 0.3
        joystickControl.alpha = 0.5
        //scnView.debugOptions = .showPhysicsShapes

    }

    func setupScene() {
        scnView.scene = mainGameScene

        //prepare game elements for later display
        createStars()
        generateWarpGrid()

        // setup HUD
        shipHud = HUD(size: self.view.bounds.size)
        scnView.overlaySKScene = shipHud
        mainGameScene.physicsWorld.contactDelegate = self
        scnView.delegate = self

        // setup scanner & galactic map views
        setupGalacticMap()
        addScanner()

        // prepare sounds
        setupPhotonSounds()
        setupGridWarpEngineSounds()
        playEngineSound(volume: 1)

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

    }

    func setupPhotonSounds() {
        var soundURL: URL?
        currentPhoton = 0
        soundURL = Bundle.main.url(forResource: "photon_sound", withExtension: "m4a")
        try! photonSound1 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound2 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound3 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound4 = AVAudioPlayer(contentsOf: soundURL!)
    }

    func createStars() {
        sectorObjectsNode.name = "sectorObjectsNode"
        let bgStars = SCNSphere(radius: 1200.0)
        let bgStarsNode = SCNNode(geometry: bgStars)
        bgStarsNode.opacity = 0.6
        let stars = UIImage(named: "Starfield 2048x1024LB.png")
        bgStarsNode.name = "BGStars"
        bgStarsNode.geometry?.firstMaterial?.diffuse.contents =  stars
        bgStarsNode.geometry?.firstMaterial?.isDoubleSided = true
        sectorObjectsNode.addChildNode(bgStarsNode)
        mainGameScene.rootNode.addChildNode(sectorObjectsNode)
        for _ in 1...Constants.numberOfStars {
            let x = randRange(lower: -50, upper: 50)
            let y = randRange(lower: -50, upper: 50)
            let z = randRange(lower: -700, upper: 700)
            let sphere = SCNSphere(radius: 0.25)
            let starSprite = SCNNode()
            starSprite.geometry  = sphere
            starSprite.position = SCNVector3Make(x, y, z)
            starSprite.geometry?.firstMaterial = SCNMaterial()
            starSprite.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            starSprite.name = "star"
            starSprites.append(starSprite)
            sectorObjectsNode.addChildNode(starSprite)
            sectorObjectsNode.renderingOrder = -1
        }
    }

    func setupShip() {
        mainGameScene.rootNode.addChildNode(self.ship)
        self.ship.position = SCNVector3(x: 0, y: 0, z: 0)

        // add forward and rear cameras
        forwardCameraNode.camera = SCNCamera()
        forwardCameraNode.camera?.wantsHDR = false
        forwardCameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        forwardCameraNode.name = "camera"
        forwardCameraNode.camera?.zFar = Constants.cameraFalloff
        self.ship.addChildNode(forwardCameraNode)

        rearCameraNode.camera=SCNCamera()
        rearCameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        rearCameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi)
        rearCameraNode.name = "rearCamera"
        rearCameraNode.camera?.zFar = Constants.cameraFalloff

        self.ship.addChildNode(rearCameraNode)

        //add shields
        let sphere = SCNSphere(radius: 3.0)
        self.zylonShields.geometry  = sphere
        self.zylonShields.opacity = 0.0064
        self.zylonShields.isHidden = true
        self.zylonShields.worldPosition = SCNVector3(x: 0, y: 0, z: 0)
        self.zylonShields.name = "zylonShields"
        self.zylonShields.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        self.zylonShields.physicsBody?.isAffectedByGravity = false
        self.zylonShields.physicsBody?.contactTestBitMask =  objectCategories.zylonShip
        self.zylonShields.physicsBody?.categoryBitMask =  objectCategories.zylonShip
//        let shieldMaterial = SCNMaterial()
//        shieldMaterial.diffuse.contents =  UIColor.green
    //    shieldMaterial.isDoubleSided = true
       // shieldMaterial.emission.contents =  UIColor.green
      //  self.zylonShields.geometry?.materials = [shieldMaterial, shieldMaterial]

        // add hull
        let zylonHullSphere = SCNSphere(radius: 3.0)
        let zylonHull = SCNNode()
        zylonHull.geometry  = zylonHullSphere
        zylonHull.opacity = 0.0064
        zylonHull.worldPosition = SCNVector3(x: 0, y: 0, z: 0)
        zylonHull.name = "zylonHull"
        zylonHull.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        zylonHull.physicsBody?.isAffectedByGravity = false
        zylonHull.physicsBody?.contactTestBitMask =  objectCategories.zylonShip
        zylonHull.physicsBody?.categoryBitMask =  objectCategories.zylonShip

     //   mainGameScene.rootNode.addChildNode(zylonShields)
        mainGameScene.rootNode.addChildNode(zylonHull)

        sectorScanCameraNode.camera = SCNCamera()
        sectorScanCameraNode.position = SCNVector3(x: 0, y: 200, z: 0)
        let cameraconstraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
        cameraconstraint.isEnabled = true
        sectorScanCameraNode.constraints = [cameraconstraint]
        sectorScanCameraNode.name = "SectorScanCamera"
        self.ship.addChildNode(sectorScanCameraNode)

        ship.currentSpeed = 5
    }

    func setupGridWarpEngineSounds() {
        var audioItems: [AVPlayerItem] = []
        let soundURL = Bundle.main.url(forResource: "warpStart", withExtension: "aif")
        let engineStart = AVPlayerItem(url: soundURL!)
        let soundURL2 = Bundle.main.url(forResource: "warpEnd", withExtension: "aif")
        let engineEnd = AVPlayerItem(url: soundURL2!)
        audioItems.append(engineStart)
        audioItems.append(engineEnd)
        warpEngineSound = AVQueuePlayer(items: audioItems)
        warpEngineSound.volume = 0.9

    }
    func addScanner() {
        zylonScanner.position = SCNVector3Make(5.5, -1.7, -8)
        mainGameScene.rootNode.addChildNode(zylonScanner)
        zylonScanner.isHidden = true
        // start scanBeam
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(2*Float.pi), z: 0, duration: 1.5)
        let perpetualRotation = SCNAction.repeatForever(rotateAction)
        zylonScanner.scanBeam.runAction(perpetualRotation)
    }

    func setupGalacticMap() {

         // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        galacticMap?.rootNode.addChildNode(cameraNode)
        galacticMap?.rootNode.rotation = SCNVector4Make(0, 1, 0, 1.571)

        let camConstraint = SCNLookAtConstraint(target: galacticMap?.rootNode)
        camConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [camConstraint]

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)

        // Add Zylons to Sector A
        for (index, element) in self.zylonFleet.sectorA.enumerated() {

            if element > 0 {
            let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            //sphereNode.geometry = SCNShape

            var childNodeName: String
            if index < 10 {
                 childNodeName = "SECTOR_ALPHA_00"+String(index)
            } else {
                 childNodeName = "SECTOR_ALPHA_0"+String(index)
            }
            galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
            print(index)
            }
        }

        // Add Zylons to Sector B
        for (index, element) in self.zylonFleet.sectorB.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                //sphereNode.geometry = SCNShape

                var childNodeName: String
                if index < 10 {
                    childNodeName = "SECTOR_BETA_00"+String(index)
                } else {
                    childNodeName = "SECTOR_BETA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

        // Add Zylons to Sector C
        for (index, element) in self.zylonFleet.sectorC.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                //sphereNode.geometry = SCNShape

                var childNodeName: String
                if index < 10 {
                    childNodeName = "SECTOR_GAMMA_00"+String(index)
                } else {
                    childNodeName = "SECTOR_GAMMA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

        // Add Zylons to Sector D
        for (index, element) in self.zylonFleet.sectorD.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                //sphereNode.geometry = SCNShape

                var childNodeName: String
                if index < 10 {
                    childNodeName = "SECTOR_4_00"+String(index)
                } else {
                    childNodeName = "SECTOR_4_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

    }
     // MARK: - Sound Functions

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

    func explosionSound() {
        let explosionArray = ["explosion", "explosion2", "explosion3", "explosion4"]
        let explosionString = explosionArray[randIntRange(lower: 0, upper: 3)]
        self.environmentSound(explosionString)
    }

    // MARK: - Ship Functions

    func setSpeed(_ newSpeed: Int) {
		let speedChange = abs(newSpeed - ship.currentSpeed)
    //    SCNTransaction.animationDuration = Double(speedChange)
		SCNTransaction.begin()
		ship.currentSpeed = newSpeed
        DispatchQueue.main.async {

		self.currentSpeedDisplay.text = "\(self.ship.currentSpeed)"
            self.stepperSpeed.value = Double(newSpeed)

        }
        SCNTransaction.commit()
        if (newSpeed == 0) {
			engineSound.setVolume(0, fadeDuration: 1.0)
        }
        if (newSpeed == 1) {
			engineSound.setVolume(1, fadeDuration: 1.0)
		}
    }

    func aftView() {
        scnView.pointOfView = rearCameraNode
        shipHud.aftView()
    }

    func foreView() {
        scnView.pointOfView = forwardCameraNode
        shipHud.foreView()

    }

    @IBAction func toggleShields(_ sender: UIButton) {
        if ship.shieldsAreUp {
            ship.shieldsAreUp = false
            envSound("shieldsDown")
        } else {
            ship.shieldsAreUp = true
            envSound("shieldsUp")

        }    }

    // MARK: - Game Event functions

    func zylonShipHit() {
        print("zylonShipHit entered. sheilds: \(ship.shieldsAreUp)")
        print("ship.shieldStrength: \(ship.shieldStrength)")

        if ship.shieldsAreUp && ship.shieldStrength > 0 {
            self.environmentSound("forcefieldHit")
            ship.shieldStrength = ship.shieldStrength - 10
            print("SHIELDS HAVE HELD! Current Shield Strenth: \(ship.shieldStrength)")
        }
        if ship.shieldStrength <= 0 || !ship.shieldsAreUp {
            self.environmentSound("hullHit")

            //ship.shieldStrength = 0
            ship.damage.shieldIntegrity = .destroyed
            print("OUTER HULL HIT! Current ship Damage: \(ship.damage)")
        }
    }

    func damageShip() {

    }

    func updateStars() {
        for star in self.starSprites {
            //if star distance is greater than 400 total
            var starScenePosition: SCNVector3
            starScenePosition = mainGameScene.rootNode.convertPosition(star.position, from: sectorObjectsNode)
            starScenePosition.z += Float(ship.currentSpeed) * Constants.starMoveDivider

            if starScenePosition.z > 300 || starScenePosition.y > 150 || starScenePosition.y < -150 {
                starScenePosition.z = randRange(lower: -400, upper: -200)
                starScenePosition.x = randRange(lower: -200, upper: 200)
                starScenePosition.y = randRange(lower: -200, upper: 200)
            }
            star.position = mainGameScene.rootNode.convertPosition(starScenePosition, to: sectorObjectsNode)
        }

    }

    func generateWarpGrid() {

        let warpGridEntryShape = SCNTube(innerRadius: 2, outerRadius: 2, height: 260)
        warpGrid.geometry  = warpGridEntryShape
        //warpGrid.geometry?.firstMaterial = SCNMaterial()
        let innerTube = SCNMaterial()
        innerTube.diffuse.contents =  UIColor.black
        innerTube.emission.contents =  UIImage(named: "smallestGrid.png")
        warpGrid.opacity = 1
        let outerTube = SCNMaterial()
        outerTube.emission.contents =  UIImage(named: "smallestGrid.png")
        outerTube.diffuse.contents = UIColor.black
        let endOne = SCNMaterial()
        endOne.diffuse.contents =  UIColor.blue
        endOne.emission.contents = UIColor.blue
        endOne.isDoubleSided = true
        warpGrid.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        warpGrid.physicsBody?.isAffectedByGravity = false
        warpGrid.physicsBody?.friction = 0
        warpGrid.physicsBody?.categoryBitMask = objectCategories.warpgrids
        warpGrid.physicsBody?.collisionBitMask = 0
        warpGrid.physicsBody?.contactTestBitMask  = 0
        warpGrid.name = "warpGrid"
        warpGrid.geometry?.materials = [outerTube, innerTube, endOne, endOne]
    //    warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.worldPosition = SCNVector3Make(0, 0, -300)
        warpGrid.scale = SCNVector3Make(1, 1, 1)
        warpGrid.opacity = 0.0
        warpGrid.physicsBody?.applyTorque(SCNVector4Make(0, 0, 1, 10), asImpulse: true)
        mainGameScene.rootNode.addChildNode(self.warpGrid)

    }

    func resetWarpgrid() {
        warpGrid.opacity = 1.0
        warpGrid.physicsBody?.velocity = SCNVector3Make(0, 0, 0)
        warpGrid.worldPosition = SCNVector3Make(0, 0, -300)
        setupGridWarpEngineSounds()
        warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.physicsBody?.applyForce(SCNVector3Make(0, 0, 125), asImpulse: true)
        warpGrid.physicsBody?.applyTorque(SCNVector4Make(0, 0, 1, 10), asImpulse: true)
        warpEngineSound.play()

    }
    func performWarp() {
        if !self.tacticalDisplay.isHidden {
            toggleTacticalDispplay(self)
        }
        resetWarpgrid()

        self.forwardCameraNode.camera?.wantsHDR = false
      //  self.forwardCameraNode.camera?.motionBlurIntensity = 1.0

        // WARP!
        SCNTransaction.begin()
     //   SCNTransaction.animationDuration = 1.5
			self.setSpeed(10)
            DispatchQueue.main.async {
			self.stepperSpeed.value = 9
            }
        SCNTransaction.commit()
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.0
        SCNTransaction.commit()
        ship.updateSector()

    }

    func turnShip() {
        if let controllerHardware = mainController?.extendedGamepad {
            let yT = controllerHardware.leftThumbstick.xAxis.value/40
            let xT = controllerHardware.leftThumbstick.yAxis.value/40
            self.rotate(self.sectorObjectsNode, around: SCNVector3Make(1, 0, 0), by: CGFloat(xT))
            self.rotate(self.sectorObjectsNode, around: SCNVector3Make(0, 1, 0), by: CGFloat(yT))

        } else {
            self.rotate(self.sectorObjectsNode, around: SCNVector3Make(1, 0, 0), by: CGFloat(self.xThrust))
            self.rotate(self.sectorObjectsNode, around: SCNVector3Make(0, 1, 0), by: CGFloat(self.yThrust))

        }

        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(1, 0, 0), by: CGFloat(self.xThrust))
        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(0, 1, 0), by: CGFloat(self.yThrust))

    }

    func enterSector() {
        print("Entering sector:", self.ship.currentSector)
        var audioItems: [AVPlayerItem] = []
        var soundURL = Bundle.main.url(forResource: "entering_sector", withExtension: "m4a")
        let sector = AVPlayerItem(url: soundURL!)
        audioItems.append(sector)
        soundURL = Bundle.main.url(forResource: ship.currentSector.quadrant.rawValue, withExtension: "m4a")

        var item = AVPlayerItem(url: soundURL!)
        audioItems.append(item)

             var numString = numberstrings[ship.currentSector.y]
             soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
             item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

            numString = numberstrings[ship.currentSector.z]
            soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
        computerVoice = AVQueuePlayer(items: audioItems)
        computerVoice.volume = 1
        computerVoice.play()
        shipHud.updateHUD()
    }

    func enterRandomSector() {
        var audioItems: [AVPlayerItem] = []
        let soundURL = Bundle.main.url(forResource: "entering_sector", withExtension: "m4a")
        let sector = AVPlayerItem(url: soundURL!)
        audioItems.append(sector)

        print("Entering sector:", terminator: "")
        for i in 1...4 {
            let randomIndex = Int(arc4random_uniform(UInt32(numberstrings.count)))
            let numString = numberstrings[randomIndex]
            if i < 4 {print(numString + "-", terminator: "")} else {print(numString)}
            let soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            let item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
        }
        computerVoice = AVQueuePlayer(items: audioItems)
        computerVoice.volume = 1
        computerVoice.play()
    }

    func updateTactical() {
        DispatchQueue.main.async {
            var rotx = self.sectorObjectsNode.eulerAngles.x.radiansToDegrees
            if rotx < 0 || rotx > 360 {
                rotx = abs(rotx.truncatingRemainder(dividingBy: 360))
            }
            var roty = self.sectorObjectsNode.eulerAngles.y.radiansToDegrees
            if roty < 0 || rotx > 360 {
                roty = abs(rotx.truncatingRemainder(dividingBy: 360))
            }

            if self.ship.shieldsAreUp {
                self.shieldsDisplay.text = "Shields: UP"
            } else {
                self.shieldsDisplay.text = "Shields: DOWN"

            }
            self.shieldStrengthDisplay.text = "Shield Strength: \(self.ship.shieldStrength)%"
            self.thetaDisplay.text = "THETA: \(rotx)"
            self.phiDisplay.text = "PHI: \(roty)"
            // self.ship.enemyShipsInSector = self.enemyShipsInSector.count
            self.enemiesInSectorDisplay.text = "Enemies In Sector: \(self.enemyShipsInSector.count)"
            if self.enemyShipCountInSector > 0 {
                let drone = self.enemyShipsInSector[0]
                self.targetDistanceDisplay.text = "DISTANCE TO TARGET - \(self.distanceBetweenPoints(first: drone.position, second: self.forwardCameraNode.position))"
            }
        }
    }

    // MARK: - Utility functioxns

    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {

        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]

            // get its material
            if (result.node.name?.contains("SECTOR"))! {
                let selectedNode = result.node
               // let material = result.node.geometry!.firstMaterial!
                let newMaterial = SCNMaterial()
                newMaterial.emission.contents = UIColor.red
                print("target sector:\(String(describing: selectedNode.name))")
                // highlight it
                SCNTransaction.begin()
             //   SCNTransaction.animationDuration = 0.5

                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
              //      SCNTransaction.animationDuration = 0.5

                    //   material.emission.contents = UIColor.black

                    SCNTransaction.commit()
                }

                //material.emission.contents = UIColor.red
                selectedNode.geometry!.firstMaterial = newMaterial
                SCNTransaction.commit()
            }
        }
    }

    func notYetImplemented(_ command: String) {
        print("\(command) not yet implemented")
        computerBeepSound("torpedo_fail")
    }

    func cleanSceneAndUpdateSectorNodeObjects() {
        var localNumberOfZylonShotsOnscreen = 0
        var localNumberOfHumonShotsOnscreen = 0
        enemyShipsInSector.removeAll()
        mainGameScene.rootNode.enumerateChildNodes({thisNode, _ in

			// if this is a torpedo, increment decay and, if a humon torpedo, move it!
            if  thisNode.name?.range(of: "torpedo") != nil {
                let thisTorp = thisNode as! Torpedo
                if thisTorp.presentation.opacity == 0 {
                    DispatchQueue.main.async {
                    thisTorp.removeFromParentNode()
                    }
                }

                 if thisTorp.torpType == TorpType.humon {
                    localNumberOfHumonShotsOnscreen += 1
                    thisTorp.worldPosition.z += Float(Constants.torpedoSpeed)
                    thisTorp.worldPosition.y -= thisTorp.worldPosition.y/Constants.torpedoCorrectionSpeedDivider
                    thisTorp.worldPosition.x -= thisTorp.worldPosition.x/Constants.torpedoCorrectionSpeedDivider
                } else {
                    localNumberOfZylonShotsOnscreen += 1
                }
                thisTorp.decay()
                if thisTorp.age == Constants.torpedoLifespan {
                    thisTorp.fade()
                }
            }

			// if this node is an explosion, update it's position (because it's not in sectorObjectsNode) and update it for decay
            if (thisNode.name == "explosionNode") {
                let thisExplosion = thisNode as! ShipExplosion
                var actualExplosionPosition = mainGameScene.rootNode.convertPosition(thisNode.position, from: sectorObjectsNode)
                actualExplosionPosition.z += Float(ship.currentSpeed)/10
                thisExplosion.position = sectorObjectsNode.convertPosition(actualExplosionPosition, from: mainGameScene.rootNode)

                thisExplosion.update()
                // if the explosion is old enough, remove it.
				if thisExplosion.age > 300 {
					thisNode.removeFromParentNode()
					explosionDuration = 0
				}
            }
            if (thisNode.name == "humonShip") {
                let thisHumonShip = thisNode as! HumonShip
                enemyShipsInSector.append(thisHumonShip)
                thisHumonShip.maneuver()
            }

			// remove warpgrid - refactor to be time since warpgrid
            if ((thisNode.worldPosition.z > 150) && (thisNode.name == "warpGrid")) {
				thisNode.opacity = 0
            }
            // update shield display to current 
            if thisNode.name == "zylonShields" {
            thisNode.isHidden = !self.ship.shieldsAreUp
            }

            self.numberOfHumanShotsOnscreen = localNumberOfHumonShotsOnscreen
            self.numberOfZylonShotsOnscreen = localNumberOfZylonShotsOnscreen

       })

}

    func numberofShotsOnscreen() -> Int {
    var numberOfShots = 0
        mainGameScene.rootNode.enumerateChildNodes({ (child, _) in
            if (child.name == "torpedo") {  numberOfShots = numberOfShots+1}
            })

    return numberOfShots
    }

    // MARK: - Collision Code

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact!")
        print("nodeA: \(String(describing: contact.nodeA.name))")
        print("nodeB: \(String(describing: contact.nodeB.name))")
        print("shield status at time of contact: \(ship.shieldsAreUp)")

        if (contact.nodeA.name == "zylonHull") {
            zylonShipHit()
            contact.nodeB.removeFromParentNode()
            return
        } else {
        if (contact.nodeB.name == "zylonHull") {
            zylonShipHit()
           contact.nodeA.removeFromParentNode()
            return
        } else {

        DispatchQueue.main.async {
            let explosionNode = ShipExplosion()
         if (contact.nodeA.name != "torpedo") {
                explosionNode.position = contact.nodeA.presentation.position

            } else {
                explosionNode.position = contact.nodeB.presentation.position
            }

            //scene.rootNode.addChildNode(explosionNode)
            self.sectorObjectsNode.addChildNode(explosionNode)

            self.explosionSound()
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            }
        }
        }
    }

    // MARK: - Game Loop

    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
     }
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        turnShip()
        zylonScanner.rotation = sectorObjectsNode.rotation
        zylonScanner.updateScanner(with: self.enemyShipsInSector)
        updateStars()
		cleanSceneAndUpdateSectorNodeObjects()
        updateTactical()
        shipHud.shields.isHidden = !ship.shieldsAreUp

    }

    // MARK: - Generic iOS Setup

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func distanceBetweenPoints(first: SCNVector3, second: SCNVector3) -> Float {
        let xDistance: Float = first.x-second.x
        let yDistance: Float = first.y-second.y
        let zDistance: Float = first.z-second.z
        let sum = xDistance * xDistance + yDistance * yDistance + zDistance * zDistance
        let result = sqrt(sum)
        return result
    }

}
