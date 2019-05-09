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
    var galacticView = SCNView.init()
    let sectorObjectsNode = SCNNode()

    let galacticMap = SCNScene(named: "galacticmap.scn")

    var forwardCameraNode = SCNNode()
    var rearCameraNode = SCNNode()
    var sectorScanCameraNode = SCNNode()
    let warpGrid = SCNNode()

    // MARK: - GameState Enums & Structs

    enum ViewMode: Int {
        case foreView
        case aftView
        case galacticMap
    }

   // var enemyDrone: SCNNode?  // this should be removed in favor of enemyShipsInSector

    // MARK: - GameState Variables

    var viewMode = ViewMode.foreView

    var currentExplosionParticleSystem: SCNParticleSystem?
    var starSprites = [SCNNode]() // array of stars to make updating them each frame easy

    var enemyFleet = GalaxyMap(withRandomlyPlacedShips: 20, maxNumberPerSector: 3)
    var enFleet = NewGalaxyMap(difficulty: 1)
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

    // gesture variables
    var currentMapAngleZ: Float = 0.0

    // MARK: - IBOutlets

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var galacticGestureView: UIView!
    @IBOutlet weak var spaceScnView: SCNView!
    @IBOutlet weak var mapScnView: SCNView!
    @IBOutlet weak var galacticStack: UIStackView!
    @IBOutlet weak var commandStack: UIStackView!
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
        print("toggling View Mode from \(viewMode)...")
        if self.viewMode == .galacticMap {
            self.viewMode = .foreView

        } else {
            self.viewMode = .galacticMap

        }
        print("to \(viewMode)")

    }

    @IBAction func toggleTacticalDisplay(_ sender: Any) {
        ship.tacticalDisplayEngaged = !ship.tacticalDisplayEngaged

    }

    @IBAction func toggleView(_ sender: UIButton) {
        if self.viewMode == .foreView {
            sender.setTitle("AFT", for: .normal)
            self.viewMode = .aftView
        } else {
            sender.setTitle("FORE", for: .normal)
            self.viewMode = .foreView

        }
        computerBeepSound("beep")

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

    func fireAftTorp() {
        print("AFT Torpedo!")
        if numberOfZylonShotsOnscreen < Constants.maxTorpedoes-2 && !self.aButtonJustPressed {
            let torpedoNode = Torpedo(designatedTorpType: .zylon)
            let photonSoundArray = [photonSound1, photonSound2, photonSound3, photonSound4]
            let currentplayer = photonSoundArray[currentPhoton]
           // let offset: Float = 4
            mainGameScene.rootNode.addChildNode(torpedoNode)
            let driftAmount: Float = 2
            let forceAmount: Float = -95
                torpedoNode.position = SCNVector3Make(-0.1, 2, 0)
                torpedoNode.physicsBody?.applyForce(SCNVector3Make(0, 0, -forceAmount), asImpulse: true)
            currentplayer?.play()
            currentPhoton = currentPhoton+1
            if currentPhoton>(photonSoundArray.count - 1) {currentPhoton = 0}
            //countNodes()
        } else {
            computerBeepSound("torpedo_fail")
        }
    }
     func fireTorp() {
        print("FireTorp!")
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
        } else {
            computerBeepSound("torpedo_fail")
        }
}

@IBAction func fireTorpedo(_ sender: UIButton) {
    if self.viewMode == .foreView { fireTorp() } else {
        if self.viewMode == .aftView { fireAftTorp() }}
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
        if !ship.isCurrentlyinWarp {
        let tacticalWasEngaged = ship.tacticalDisplayEngaged
        performWarp()
		let deadlineTime = DispatchTime.now() + .seconds(6)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.enterSector()
			self.setSpeed(3)
            self.forwardCameraNode.camera?.motionBlurIntensity = 0
            self.ship.isCurrentlyinWarp = false
            self.ship.tacticalDisplayEngaged = tacticalWasEngaged
		}
        let spawnDeadline = DispatchTime.now() + .seconds(8)
        DispatchQueue.main.asyncAfter(deadline: spawnDeadline) {
           // self.warpGrid.removeFromParentNode()
            self.spawnDrones(number: Int(randRange(lower: 2, upper: 6)))
        }
        } else {
            computerBeepSound("torpedo_fail")
        }

    }

    @IBAction func speedChanged(_ sender: UIStepper) {
        computerBeepSound("beep")
        let targetSpeed = sender.value
        setSpeed(Int(targetSpeed))
    }

    let rotateSpeed = 0.5
    var alphaSector: SCNNode { return (galacticMap?.rootNode.childNode(withName: "ALPHA", recursively: true))! }
    var betaSector: SCNNode { return (galacticMap?.rootNode.childNode(withName: "BETA", recursively: true))! }
    var gammaSector: SCNNode { return (galacticMap?.rootNode.childNode(withName: "GAMMA", recursively: true))! }
    var deltaSector: SCNNode { return (galacticMap?.rootNode.childNode(withName: "DELTA", recursively: true))! }

    var rotationNode: SCNNode { return  (galacticMap?.rootNode.childNode(withName: "rotateNode", recursively: true))! }

    @IBAction func alpha(_ sender: Any) {
        computerBeepSound("beep")
        let action = SCNAction.rotateTo(x: 0.1, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
            rotationNode.runAction(action)
            alphaSector.opacity = 1.0
            betaSector.opacity = Constants.mapTransparency
            gammaSector.opacity = Constants.mapTransparency
            deltaSector.opacity = Constants.mapTransparency
        envSound("AlphaSector")

    }
    @IBAction func beta(_ sender: Any) {
        computerBeepSound("beep")

            let action = SCNAction.rotateTo(x: 0, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
            rotationNode.runAction(action)
        alphaSector.opacity = Constants.mapTransparency
        betaSector.opacity = 1.0
        gammaSector.opacity = Constants.mapTransparency
        deltaSector.opacity = Constants.mapTransparency
        envSound("BetaSector")

    }
    @IBAction func gamma(_ sender: Any) {
        computerBeepSound("beep")

        let action = SCNAction.rotateTo(x: -0.1, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
        rotationNode.runAction(action)
        alphaSector.opacity = Constants.mapTransparency
        betaSector.opacity = Constants.mapTransparency
        gammaSector.opacity = 1.0
        deltaSector.opacity = Constants.mapTransparency
        envSound("GammaSector")

    }
    @IBAction func delta(_ sender: Any) {
        computerBeepSound("beep")

        let action = SCNAction.rotateTo(x: -0.16, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
        rotationNode.runAction(action)
        alphaSector.opacity = Constants.mapTransparency
        betaSector.opacity = Constants.mapTransparency
        gammaSector.opacity = Constants.mapTransparency
        deltaSector.opacity = 1.0
        envSound("DeltaSector")

    }

    @IBAction func allQuads(_ sender: Any) {
        let action = SCNAction.rotateTo(x: -0.5, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
        rotationNode.runAction(action)
        computerBeepSound("beep")
        alphaSector.opacity = 1.0
        betaSector.opacity = 1.0
        gammaSector.opacity = 1.0
        deltaSector.opacity = 1.0
    }

    // MARK: - SETUP

    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.controllerWasConnected),
//                                               name: NSNotification.Name.GCControllerDidConnect,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.controllerWasDisconnected),
//                                               name: NSNotification.Name.GCControllerDidDisconnect,
//                                               object: nil)
        setupView()
        setupScene()
        setupShip()
        spawnDrones(number: 3)
       // myMCController.setup()
       // myMCController.myCommandDelegate = self
        shipHud.parentScene = self

    }

    func setupView() {
        scnView = spaceScnView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        scnView.backgroundColor = UIColor.black
        joystickControl.movable = false
        joystickControl.baseAlpha = 0.3
        joystickControl.alpha = 0.2
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
        cameraNode.name = "gCam"

        galacticMap?.rootNode.addChildNode(cameraNode)
        rotationNode.rotation = SCNVector4Make(0, 0, 1, 3.141)

        let camConstraint = SCNLookAtConstraint(target: galacticMap?.rootNode)
        camConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [camConstraint]

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: -8, z: 4.2)

        
        // refactored add enemyFleet  to alpha Sector
        var index = 0
        for currentIndex  in self.enFleet.alphaQuadrant.min...self.enFleet.alphaQuadrant.max {
            let currentCount = self.enFleet.map[currentIndex].ships.count
            switch currentCount {
            case 0:
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                var childNodeName: String
                if index < 10 {
                    childNodeName = "ALPHA_00"+String(index)
                } else {
                    childNodeName = "ALPHA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(currentCount) zylons from SectorA[\(index)]")
            case 1:
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                var childNodeName: String
                if index < 10 {
                    childNodeName = "ALPHA_00"+String(index)
                } else {
                    childNodeName = "ALPHA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(currentCount) = 1 zylon from SectorA[\(index)]")
            case 2:
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                var childNodeName: String
                if index < 10 {
                    childNodeName = "ALPHA_00"+String(index)
                } else {
                    childNodeName = "ALPHA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(currentCount) = 2 zylons from SectorA[\(index)]")
            case 3:
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                var childNodeName: String
                if index < 10 {
                    childNodeName = "ALPHA_00"+String(index)
                } else {
                    childNodeName = "ALPHA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(currentCount) = 3 zylons from SectorA[\(index)]")
            case 4:
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                var childNodeName: String
                if index < 10 {
                    childNodeName = "ALPHA_00"+String(index)
                } else {
                    childNodeName = "ALPHA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(currentCount) = 4 zylons from SectorA[\(index)]")
            default:
                print ("no enemies to add to index \(currentIndex)")
                
            }
            index += 1
        }
        
        
        // Add Zylons to Sector Alpha
        print("adding zylons to Sector Alpha")

        for (index, element) in self.enemyFleet.alphaSector.enumerated() {

            if element > 0 {
            let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

            var childNodeName: String
            if index < 10 {
                 childNodeName = "ALPHA_00"+String(index)
            } else {
                 childNodeName = "ALPHA_0"+String(index)
            }
            galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
            print(index)
            } else {print("no zylons to add to ALPHA sector")}
        }

        // Add Zylons to Sector Beta
        print("adding zylons to Sector Beta")

        for (index, element) in self.enemyFleet.betaSector.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                //sphereNode.geometry = SCNShape

                var childNodeName: String
                if index < 10 {
                    childNodeName = "BETA_00"+String(index)
                } else {
                    childNodeName = "BETA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

        // Add Zylons to Sector Gamma
        print("adding zylons to Sector Gamma")
        for (index, element) in self.enemyFleet.gammaSector.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                //sphereNode.geometry = SCNShape

                var childNodeName: String
                if index < 10 {
                    childNodeName = "GAMMA_00"+String(index)
                } else {
                    childNodeName = "GAMMA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

        // Add Zylons to Sector Delta
        print("adding zylons to Sector Delta")

        for (index, element) in self.enemyFleet.deltaSector.enumerated() {

            if element > 0 {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: Constants.galacticMapBlipRadius))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                var childNodeName: String
                if index < 10 {
                    childNodeName = "DELTA_00"+String(index)
                } else {
                    childNodeName = "DELTA_0"+String(index)
                }
                galacticMap?.rootNode.childNode(withName: childNodeName, recursively: true)?.addChildNode(sphereNode)
                print("childNodeName: \(childNodeName) should have \(element) zylons from SectorA[\(index)]")
                print(index)
            }
        }

        var  rotationNode: SCNNode { return  (galacticMap?.rootNode.childNode(withName: "rotateNode", recursively: true))! }

        // creae pan recognizer
        let mapPan = UIPanGestureRecognizer(target: self, action: #selector(mapPan(_:)))
    self.galacticGestureView.addGestureRecognizer(mapPan)

        // add mapView

        let transition = SKTransition.fade(withDuration: 0)
        mapScnView.present(galacticMap!, with: transition, incomingPointOfView: galacticMap?.rootNode.childNode(withName: "gCam", recursively: true), completionHandler: {
            self.mapScnView.allowsCameraControl = false
            print(self.mapScnView.description) })
    }

    // MARK: - Map rotator
    @objc func mapPan(_ gesture: UIPanGestureRecognizer) {
        print("Map Panned")
        var rotationNode: SCNNode { return  (galacticMap?.rootNode.childNode(withName: "rotateNode", recursively: true))! }

//        let translation = gesture.translation(in: gesture.view)
//
//        let x = Float(translation.x)
//        //let y = Float(-translation.y)
//
//        let anglePan = sqrt(pow(x, 2)+pow(y, 2))*(Float)(M_PI)/180.0
//
//        var rotationVector = SCNVector4()
//        rotationVector.x = -y
//        rotationVector.y = x
//        rotationVector.z = 0
//        rotationVector.w = anglePan
//
//        rotationNode.rotation = rotationVector
//
//        //geometryNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)
//
//        if gesture.state == .ended {
//
//            let currentPivot = rotationNode.pivot
//            let changePivot = SCNMatrix4Invert( rotationNode.transform)
//
//            rotationNode.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//
//            rotationNode.transform = SCNMatrix4Identity
//        }

        let translation = gesture.translation(in: gesture.view)

        var newAngleZ = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleZ += currentMapAngleZ

        rotationNode.eulerAngles.z = newAngleZ

        if gesture.state == .ended {
           currentMapAngleZ = newAngleZ
        }

    }

    // MARK: - Ship Functions

    func setSpeed(_ newSpeed: Int) {
	//	let speedChange = abs(newSpeed - ship.currentSpeed)
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

//    func aftView() {
//        viewMode = .aftView
//    }
//
//    func foreView() {
//        viewMode = .foreView
//
//    }

    @IBAction func toggleShields(_ sender: UIButton) {
        if ship.shieldsAreUp {
            ship.shieldsAreUp = false
            envSound("shieldsDown")
        } else {
            if ship.shipSystems.shieldIntegrity != .destroyed {
            ship.shieldsAreUp = true
            envSound("shieldsUp")
            } else {
                computerBeepSound("torpedo_fail")
            }

        }    }

    // MARK: - Game Event functions

    func humonShipHit(nodeA: SCNNode, nodeB: SCNNode) {
        boom(atNode: nodeA)
    }
    func zylonShipHitBy(node: SCNNode) {
        print("Zylon Ship hit by \(node.description)")

        // we should animate removal of node which hit ship, but for now just remove it.
        if !ship.shieldsAreUp {
        boom(atNode: node)
        }
        node.removeFromParentNode()
       // self.shipHud.updateHUD()

        if ship.shieldsAreUp && ship.shieldStrength>0 {
            print("ship.shieldsAreUp && ship.shieldStrength>0")
            self.environmentSound("forcefieldHit")
            print("self.environmentSound(forcefieldHit) played")

            let overlayPos = self.overlayPos(node: node) // screen coordinates of hit in UIVIew

            DispatchQueue.main.async {
                let testView = UIView(frame: CGRect(x: overlayPos.x-5, y: overlayPos.y-5, width: 30, height: 30))
                testView.tintColor = UIColor.red
                testView.backgroundColor = UIColor.red
                self.mainView.addSubview(testView)
                testView.setNeedsDisplay()

                DispatchQueue.main.asyncAfter(deadline: .now() + 10.5) {
                testView.removeFromSuperview()
                }
            }

            let overlaySpritePOS = shipHud.convertPoint(fromView: overlayPos) //
            shipHud.shieldHit(location: overlaySpritePOS)
            ship.shieldStrength = ship.shieldStrength - 10
            if ship.shieldStrength>0 {
            print("SHIELDS HAVE HELD! Current Shield Strenth: \(ship.shieldStrength)")
            } else {
                self.shipHud.activateAlert(message: "SHIELDS FAILURE!")
            }

        } else {
            print("hullHit sound because sheilds are down")

            self.environmentSound("hullHit")
            ship.takeDamage()
        }
    }

    func boom(atNode: SCNNode) {
        print("BOOM!")
        DispatchQueue.main.async {
            let explosionNode = ShipExplosion()
            explosionNode.position = atNode.presentation.position
            self.sectorObjectsNode.addChildNode(explosionNode)
            self.explosionSound()
        }
        //self.shipHud.updateHUD()

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
        ship.isCurrentlyinWarp = true
        if ship.tacticalDisplayEngaged {
            toggleTacticalDisplay(self)
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
//        SCNTransaction.begin()
//        SCNTransaction.animationDuration = 0.0
//        SCNTransaction.commit()
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

        // quadrant
        soundURL = Bundle.main.url(forResource: ship.currentSector.quadrant.rawValue, withExtension: "m4a")
        var item = AVPlayerItem(url: soundURL!)
        audioItems.append(item)

        // x coordinate
        if ship.currentSector.qx < 10 {
            let numString = numberstrings[ship.currentSector.qx]
             soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
             item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

        // y coordinate
        } else {
            let numString = numberstrings[ship.currentSector.qx-10]
            soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
            let numString2 = numberstrings[1]
            soundURL = Bundle.main.url(forResource: numString2, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

        }
        if ship.currentSector.qy < 10 {
            let numString = numberstrings[ship.currentSector.qy]
            soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
        } else { // break numb7ers greater than 9 into two digits
            let numString2 = numberstrings[1]
            soundURL = Bundle.main.url(forResource: numString2, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
            let numString = numberstrings[ship.currentSector.qy-10]
            soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            let lastItem = AVPlayerItem(url: soundURL!)
            audioItems.append(lastItem)

        }
        computerVoice = AVQueuePlayer(items: audioItems)
        computerVoice.volume = 1
        computerVoice.play()
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
        if ship.tacticalDisplayEngaged && !ship.isCurrentlyinWarp {
            DispatchQueue.main.async {

            self.tacticalDisplay.isHidden = false
            self.zylonScanner.isHidden = false
            var rotx = self.sectorObjectsNode.eulerAngles.x.radiansToDegrees
            if rotx < 0 || rotx > 360 {
                rotx = abs(rotx.truncatingRemainder(dividingBy: 360))
            }
            var roty = self.sectorObjectsNode.eulerAngles.y.radiansToDegrees
            if roty < 0 || rotx > 360 {
                roty = abs(rotx.truncatingRemainder(dividingBy: 360))
            }

            if self.ship.shieldsAreUp {
                self.shieldsDisplay.text = "Shields: \(self.ship.shipSystems.shieldIntegrity)"
            } else {
                self.shieldsDisplay.text = "Shields: DOWN"

            }
            self.shieldStrengthDisplay.text = "Shield Strength: \(self.ship.shieldStrength)%"
            let roundedX = round(rotx * 100) / 100
            let roundedY = round(roty * 100) / 100

            self.thetaDisplay.text = "Θ: \(roundedX)"
            self.phiDisplay.text = "ɸ: \(roundedY)"
            // self.ship.enemyShipsInSector = self.enemyShipsInSector.count
            self.enemiesInSectorDisplay.text = "Enemies In Sector: \(self.enemyShipsInSector.count)"
            if self.enemyShipCountInSector > 0 {
                let drone = self.enemyShipsInSector[0]
                self.targetDistanceDisplay.text = "DISTANCE TO TARGET - \(distanceBetweenPoints(first: drone.position, second: self.forwardCameraNode.position))"
            }
        }
        } else {
            DispatchQueue.main.async {

            self.tacticalDisplay.isHidden = true
            self.zylonScanner.isHidden = true
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

    // MARK: - Collision Code

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact!")
        print("nodeA: \(String(describing: contact.nodeA.name!))")
        print("nodeB: \(String(describing: contact.nodeB.name!))")
        print("shield status at time of contact: \(ship.shieldsAreUp)")

        if (contact.nodeA.name == "zylonHull") {
            zylonShipHitBy(node: contact.nodeB)
            return
        } else {
        if (contact.nodeB.name == "zylonHull") {
            zylonShipHitBy(node: contact.nodeA)
            return
        } else {
        DispatchQueue.main.async {
            self.humonShipHit(nodeA: contact.nodeA, nodeB: contact.nodeB)
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
        //self.shipHud.updateHUD()

         DispatchQueue.main.async {
            self.shipHud.shields.isHidden = !self.ship.shieldsAreUp
        }

        switch self.viewMode {

        case .aftView:
            DispatchQueue.main.async {
                self.joystickControl.isHidden = false
                self.mapScnView.isHidden = true
                self.scnView.isHidden = false
                self.galacticStack.isHidden = true
                self.commandStack.isHidden = false
                self.scnView.pointOfView = self.rearCameraNode
                //self.shipHud.aftView()
                self.galacticGestureView.isHidden = true

            }
        case .foreView:
                DispatchQueue.main.async {
                    self.joystickControl.isHidden = false
                    self.mapScnView.isHidden = true
                    self.scnView.isHidden = false
                    self.galacticStack.isHidden = true
                    self.commandStack.isHidden = false
                    self.spaceScnView.pointOfView = self.forwardCameraNode
                    self.shipHud.foreView()
                    self.galacticGestureView.isHidden = true

            }
        case .galacticMap:
                DispatchQueue.main.async {
                    self.joystickControl.isHidden = false
                    self.mapScnView.isHidden = false
                    self.scnView.isHidden = true
                    self.galacticStack.isHidden = false
                    self.commandStack.isHidden = true
                    self.galacticGestureView.isHidden = false
            }
        }

    }

    // MARK: - Generic iOS Setup

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
