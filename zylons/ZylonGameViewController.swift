//
//  ZylonGameViewController.swift
//  Zylon Defenders
//
//  Created by Jeffery Glasse on 11/6/16.
//  Copyright © 2016 Jeffery Glasse. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion
import MultipeerConnectivity

class ZylonGameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    // MARK: - Multipeer
    var myMCController = MCController.sharedInstance

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

    var enemyDrone: SCNNode?  // this should be removed in favor of enemyShipsInSector

    var enemyShipsInSector = [HumonShip]()
    var enemyShipCountInSector: Int {
        return enemyShipsInSector.count
    }

	var ship = ZylonShip()
    var zylonShields = SCNNode()

	var shipHud: HUD!

    var zylonScanner = Scanner()

    let divider: Float = 100.0
    var xThrust: Float { return Float(sin(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}
    var yThrust: Float { return Float(cos(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}

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

    var motionManager: CMMotionManager!

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
    @IBOutlet weak var velocityDisplay: UILabel!
    @IBOutlet weak var targetDistanceDisplay: UILabel!
    @IBOutlet weak var enemiesInSectorDisplay: UILabel!

    // MARK: - IBActions

    @IBAction func showMap(_ sender: Any) {

        if scnView.scene   == galacticMap {
            scnView.scene = mainGameScene
            scnView.allowsCameraControl = false

        } else {
            scnView.scene = galacticMap
            scnView.allowsCameraControl = true

        }

    }

    @IBAction func showTactical(_ sender: Any) {
        tacticalDisplay.isHidden = !tacticalDisplay.isHidden
        zylonScanner.isHidden = tacticalDisplay.isHidden

    }
    @IBAction func showShortRangeScan(_ sender: Any) {
        sectorScan()

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
        let soundURL = Bundle.main.url(forResource: soundString, withExtension: "mp3")
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

    @IBAction func fireTorpedo(_ sender: UIButton) {
        if numberOfZylonShotsOnscreen < Constants.maxTorpedoes {
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
            self.warpGrid.removeFromParentNode()
            self.spawnDrones(number: Int(randRange(lower: 2, upper: 6)))
        }

    }

    @IBAction func speedChanged(_ sender: UIStepper) {
        computerBeepSound("beep")
        let targetSpeed = sender.value
        setSpeed(Int(targetSpeed))
    }

    // MARK: - SETUP

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupShip()
        spawnDrones(number: 3)
       // myMCController.setup()
       // myMCController.myCommandDelegate = self
        shipHud.parentScene = self
    }

    func setupView() {
        scnView = self.view as! SCNView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true

        //scnView.debugOptions = .showPhysicsShapes
        scnView.isPlaying = true
        scnView.backgroundColor = UIColor.black
        joystickControl.movable = false
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

        // setup scanner viewa
        setupGalacticMap()
        addScanner()

        // prepare sounds
        setupPhotonSounds()
        setupGridWarpEngineSounds()
        playEngineSound(volume: 1)

    }

    func setupPhotonSounds() {
        var soundURL: URL?
        currentPhoton = 0
        soundURL = Bundle.main.url(forResource: "photon_sound", withExtension: "mp3")
        try! photonSound1 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound2 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound3 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound4 = AVAudioPlayer(contentsOf: soundURL!)
    }

    func createStars() {
        sectorObjectsNode.name = "sectorObjectsNode"
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
        let sphere = SCNSphere(radius: 180.0)
        self.zylonShields.geometry  = sphere
        zylonShields.opacity = 1
        self.zylonShields.worldPosition = SCNVector3(x: 0, y: 0, z: 0)
        self.zylonShields.name = "zylonShields"
        self.zylonShields.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        let shieldMaterial = SCNMaterial()
        shieldMaterial.diffuse.contents =  UIColor.green
        shieldMaterial.emission.contents =  UIColor.green
        self.zylonShields.geometry?.materials = [shieldMaterial, shieldMaterial]
        self.ship.addChildNode(zylonShields)

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
        zylonScanner.position = SCNVector3Make(-3.7, -1.7, -8)
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

        let camConstraint = SCNLookAtConstraint(target: galacticMap?.rootNode)
        camConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [camConstraint]

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)

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
        environmentSound.volume = 0.5
        environmentSound.play()
    }

    // MARK: - Ship Functions

    func setSpeed(_ newSpeed: Int) {
		let speedChange = abs(newSpeed - ship.currentSpeed)
        SCNTransaction.animationDuration = Double(speedChange)
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

    func sectorScan() {
//        if scnView.pointOfView != sectorScanCameraNode {scnView.pointOfView = sectorScanCameraNode } else {
//            scnView.pointOfView = forwardCameraNode
//        }
        self.notYetImplemented("sectorScan")

    }
    func aftView() {
        scnView.pointOfView = rearCameraNode
        shipHud.aftView()
    }

    func foreView() {
        scnView.pointOfView = forwardCameraNode
        shipHud.foreView()

    }

    @IBAction func Shields(_ sender: UIButton) {
        shipHud.toggleShields()
        computerBeepSound("shields")
    }

	func toggleShields() {
        shipHud.toggleShields()
        computerBeepSound("shields")
    }

    // MARK: - Game Event functions

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
        warpGrid.opacity = 0.35
        let outerTube = SCNMaterial()
        outerTube.emission.contents =  UIImage(named: "smallestGrid.png")
        outerTube.diffuse.contents = UIColor.black
        let endOne = SCNMaterial()
        //endOne.diffuse.contents =  UIColor.blue
        let endTwo = SCNMaterial()
        //endTwo.diffuse.contents =  UIColor.purple
        warpGrid.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        warpGrid.physicsBody?.isAffectedByGravity = false
        warpGrid.physicsBody?.friction = 0
        warpGrid.physicsBody?.categoryBitMask = objectCategories.warpgrids
        warpGrid.physicsBody?.contactTestBitMask  = 0
        warpGrid.name = "warpGrid"
        warpGrid.geometry?.materials = [outerTube, innerTube, endOne, endTwo]
        // warpGrid.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.worldPosition = SCNVector3Make(0, 0, -300)
        warpGrid.scale = SCNVector3Make(1, 1, 1)
        warpGrid.opacity = 0.0

        mainGameScene.rootNode.addChildNode(self.warpGrid)
    }

    func resetWarpgrid() {
        warpGrid.opacity = 1.0
        warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.worldPosition = SCNVector3Make(0, 0, -300)
        warpGrid.physicsBody?.applyForce(SCNVector3Make(0, 0, 95), asImpulse: true)
    }
    func performWarp() {
        warpEngineSound.play()
        resetWarpgrid()
        self.forwardCameraNode.camera?.wantsHDR = false
        self.forwardCameraNode.camera?.motionBlurIntensity = 1.0

        // WARP!
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
			self.setSpeed(30)
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
        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(1, 0, 0), by: CGFloat(self.yThrust))
        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(0, 1, 0), by: CGFloat(self.xThrust))

    }

    func enterSector() {
        print("Entering sector:", self.ship.currentSector)
        var audioItems: [AVPlayerItem] = []
        var soundURL = Bundle.main.url(forResource: "entering_sector", withExtension: "m4a")
        let sector = AVPlayerItem(url: soundURL!)
        audioItems.append(sector)
            var numString = numberstrings[ship.currentSector.x]
             soundURL = Bundle.main.url(forResource: numString, withExtension: "m4a")
            var item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

             numString = numberstrings[ship.currentSector.y]
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

    // MARK: - Utility functioxns

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
                    print("fading torpedo!")
                    thisTorp.fade()
                }
            }

			// remove explosions - refactor to provide timer for each explosion
            if (thisNode.name == "explosionNode") {
                let thisExplosion = thisNode as! ShipExplosion
                var actualExplosionPosition = mainGameScene.rootNode.convertPosition(thisNode.position, from: sectorObjectsNode)
                actualExplosionPosition.z += Float(ship.currentSpeed)/10
                thisExplosion.position = sectorObjectsNode.convertPosition(actualExplosionPosition, from: mainGameScene.rootNode)

                thisExplosion.update()

				if thisExplosion.age > 300 {
					thisNode.removeFromParentNode()
					explosionDuration = 0
				}
            }
            if (thisNode.name == "drone") {
                let thisDrone = thisNode as! HumonShip
                enemyShipsInSector.append(thisDrone)
                thisDrone.maneuver()
            }

			// remove warpgrid - refactor to be time since warpgrid
            if ((thisNode.presentation.position.z > 110) && (thisNode.name == "warpGrid")) {
				SCNTransaction.animationDuration = 0
				SCNTransaction.begin()
				thisNode.opacity = 0
				SCNTransaction.commit()
            }
            self.numberOfHumanShotsOnscreen = localNumberOfHumonShotsOnscreen
            self.numberOfZylonShotsOnscreen = localNumberOfZylonShotsOnscreen

       })

}

    func countNodes() {
//        var numberofNodes = 0
//        scene.rootNode.enumerateChildNodes { (_, _) -> Void in
//            numberofNodes = numberofNodes + 1
//        }
//        print("number of live nodes:\(numberofNodes)")

    }

    func numberofShotsOnscreen() -> Int {
    var numberOfShots = 0
        mainGameScene.rootNode.enumerateChildNodes({ (child, _) in
            if (child.name == "torpedo") {  numberOfShots = numberOfShots+1}
            })

    return numberOfShots
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        DispatchQueue.main.async {
            let explosionNode = ShipExplosion()
         if (contact.nodeA.name != "torpedo") {
                explosionNode.position = contact.nodeA.presentation.position

            } else {
                explosionNode.position = contact.nodeB.presentation.position
            }
            print("contact.nodeA.name: \(String(describing: contact.nodeA.name))")
            print("contact.nodeA.position: \(contact.nodeA.worldPosition)")
            print("contact.nodeB.name: \(String(describing: contact.nodeB.name))")
            print("contact.nodeB.position: \(contact.nodeB.worldPosition)")

            //scene.rootNode.addChildNode(explosionNode)
            self.sectorObjectsNode.addChildNode(explosionNode)
            self.environmentSound("explosion")
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()

        }
    }

    func updateTactical() {
        DispatchQueue.main.async {
            var rotx = self.sectorObjectsNode.rotation.x.radiansToDegrees
            if rotx < 0 || rotx > 360 {
                rotx = rotx.truncatingRemainder(dividingBy: 360)
            }

            self.thetaDisplay.text = "THETA: \(rotx)º"
            self.phiDisplay.text = "PHI: \(self.sectorObjectsNode.rotation.y.radiansToDegrees)"
            self.ship.enemyShipsInSector = self.enemyShipsInSector.count
            self.enemiesInSectorDisplay.text = "Enemies In Sector: \(self.ship.enemyShipsInSector)"
            if self.enemyShipCountInSector > 0 {
            let drone = self.enemyShipsInSector[0]
            self.targetDistanceDisplay.text = "DISTANCE TO TARGET - \(self.distanceBetweenPoints(first: drone.position, second: self.forwardCameraNode.position))"
            }
        }

    }

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
