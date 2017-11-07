//
//  GameViewController.swift
//  Zylon Defenders
//
//  Created by Jeffery Glasse on 11/6/16.
//  Copyright © 2016 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion
import MultipeerConnectivity

struct Constants {
    static let maxTorpedoes = 5
    static let torpedoLifespan = 90
    static let shotDelay = 1
    static let thrustAmount: Float = 5.0
    static let numberOfStars = 110
    static let xAxis = SCNVector3Make(1, 0, 0)
    static let yAxis = SCNVector3Make(0, 1, 0)
    static let zAxis = SCNVector3Make(0, 0, 1)
    static let starBoundsX = 200
    static let starBoundsY = 500
    static let starBoundsZ = 500
    static let cameraFalloff = 500.0
    static let minHumonTorpedoCycles: Float = 45
    static let maxHumonTorpedoCycles: Float = 300

}

@available(iOS 11.0, *)
class GameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    // MARK: -
    // MARK: Constants

    // add multipeer Connectivity
    var myMCController = MCController.sharedInstance

    // MARK: -
    // MARK: Vars
    // drone model
    var droneModel: SCNNode!

    // Scenes, Views and Nodes
    var scene: SCNScene!
    var scnView: SCNView!
    let sectorObjectsNode = SCNNode()

    var cameraNode = SCNNode()
    var rearCameraNode = SCNNode()
    var sectorScanCameraNode = SCNNode()
    let warpGrid = SCNNode()

    var currentExplosionParticleSystem: SCNParticleSystem?
	var starSprites = [SCNNode]()

    var enemyDrone: SCNNode?

	var ship = ZylonShip()
	var shipHud: HUD!

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
    var currentPhoton = 0
//    var currentMaxRotX: Double = 0.0
//    var currentMaxRotY: Double = 0.0
//    var currentMaxRotZ: Double = 0.0
//
    private var timeFiring = 0.0
    private var timeLastFired = 0.0

    // MARK: - IBOutlets

    @IBOutlet weak var joystickControl: JoyStickView!
    @IBOutlet weak var tacticalDisplay: UIView!

	@IBOutlet weak var currentSpeedDisplay: UILabel!
	@IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var phiDisplay: UILabel!
    @IBOutlet weak var thetaDisplay: UILabel!
    @IBOutlet weak var velocityDisplay: UILabel!
    @IBOutlet weak var targetDistanceDisplay: UILabel!
    @IBOutlet weak var xThrustLabel: UILabel!
    @IBOutlet weak var yThrustLabel: UILabel!

    // MARK: - IBActions

    @IBAction func showTactical(_ sender: Any) {
        tacticalDisplay.isHidden = !tacticalDisplay.isHidden

    }
    @IBAction func showShortRangeScan(_ sender: Any) {
        //sectorScan()
        computerBeepSound("torpedo_fail")

    }
    @IBAction func toggleView(_ sender: UIButton) {
		SCNTransaction.animationDuration = 0.0

		if scnView.pointOfView == cameraNode {
			sender.setTitle("AFT", for: .normal)
            aftView()
        } else {
			sender.setTitle("FORE", for: .normal)
            foreView()
        }
        computerBeepSound("beep")
		SCNTransaction.animationDuration = 0.0

    }

    func fireHumonTorpedo(fromShip: HumonShip) {
        let torpedoNode = Torpedo(designatedTorpType: .humon)
        scene.rootNode.addChildNode(torpedoNode)
        let driftAmount: Float = 2
        let forceAmount: Float = 95
            torpedoNode.worldPosition = fromShip.worldPosition
            torpedoNode.physicsBody?.applyForce(SCNVector3Make(-driftAmount, 1.7, forceAmount), asImpulse: true)
    }

    @IBAction func fireTorpedo(_ sender: UIButton) {
        if (numberofShotsOnscreen() < Constants.maxTorpedoes) {
            let torpedoNode = Torpedo()

			let photonSoundArray = [photonSound1, photonSound2, photonSound3, photonSound4]
			let currentplayer = photonSoundArray[currentPhoton]

			scene.rootNode.addChildNode(torpedoNode)
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
          countNodes()
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

        self.enemyDrone = HumonShip()

        let constraint = SCNLookAtConstraint(target: scene.rootNode)
        constraint.isGimbalLockEnabled = true
        self.enemyDrone?.constraints = [constraint]

        let actualPosition = self.scene.rootNode.convertPosition((self.enemyDrone?.position)!, from: self.enemyDrone)
        let seccondActualPosition = self.enemyDrone?.worldPosition
        print("actualPosition:\(actualPosition)")
        print("seccondActualPosition:\(seccondActualPosition)")

        self.enemyDrone?.position = self.scene.rootNode.convertPosition(actualPosition, to: self.sectorObjectsNode)
        self.sectorObjectsNode.addChildNode(self.enemyDrone!)
    }

	@IBOutlet weak var stepperSpeed: UIStepper!
	@IBAction func gridWarp(_ sender: UIButton) {
        performWarp()
		let deadlineTime = DispatchTime.now() + .seconds(6)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.enterSector()
			self.setSpeed(1)
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
        createStars()
        setupShip()
        myMCController.setup()
        myMCController.myCommandDelegate = self
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
        scene = SCNScene()
        scnView.scene = scene

        // setup HUD
        shipHud = HUD(size: self.view.bounds.size)
        scnView.overlaySKScene = shipHud
        scene.physicsWorld.contactDelegate = self
        scnView.delegate = self
        setupPhotonSounds()
        prepWarpEngines()
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
        scene.rootNode.addChildNode(sectorObjectsNode)
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
        scene.rootNode.addChildNode(self.ship)
        self.ship.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.focalSize = 10
        cameraNode.camera?.focalBlurRadius = 100
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.name = "camera"
        cameraNode.camera?.zFar = Constants.cameraFalloff
        //cameraNode.camera?.fieldOfView = 120

        self.ship.addChildNode(cameraNode)

        rearCameraNode.camera=SCNCamera()
        rearCameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        rearCameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi)
        rearCameraNode.name = "rearCamera"
        rearCameraNode.camera?.zFar = 400

        self.ship.addChildNode(rearCameraNode)

        sectorScanCameraNode.camera = SCNCamera()
        sectorScanCameraNode.position = SCNVector3(x: 0, y: 200, z: 0)
        let cameraconstraint = SCNLookAtConstraint(target: scene.rootNode)
        cameraconstraint.isEnabled = true
        sectorScanCameraNode.constraints = [cameraconstraint]
        sectorScanCameraNode.name = "SectorScanCamera"
        self.ship.addChildNode(sectorScanCameraNode)

        ship.currentSpeed = 5
    }

    func prepWarpEngines() {
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

    func computerBeepSound(_ soundString: String) {
       let soundURL = Bundle.main.url(forResource: soundString, withExtension: "mp3")
       try! beepsound = AVAudioPlayer(contentsOf: soundURL!)
        beepsound.volume = 0.5
        beepsound.play()
    }

    // MARK: - Ship Functions

    func setSpeed(_ newSpeed: Int) {
		let speedChange = abs(newSpeed - ship.currentSpeed)
        SCNTransaction.animationDuration = Double(speedChange)
		SCNTransaction.begin()
		ship.currentSpeed = newSpeed
        DispatchQueue.main.async {

		self.currentSpeedDisplay.text = "\(self.ship.currentSpeed)"
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
    scnView.pointOfView = sectorScanCameraNode

    }
    func aftView() {
        scnView.pointOfView = rearCameraNode
        shipHud.aftView()
    }

    func foreView() {
        scnView.pointOfView = cameraNode
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
            // TODO: refactor to calculate ship vector on all three axes

            //if star distance is greater than 400 total
            var starScenePosition: SCNVector3
            starScenePosition = scene.rootNode.convertPosition(star.position, from: sectorObjectsNode)
            starScenePosition.z += Float(ship.currentSpeed)

            if starScenePosition.z > 300 || starScenePosition.y > 150 || starScenePosition.y < -150 {
                starScenePosition.z = randRange(lower: -400, upper: -200)
                starScenePosition.x = randRange(lower: -100, upper: 100)
                starScenePosition.y = randRange(lower: -100, upper: 100)
            }
            star.position = scene.rootNode.convertPosition(starScenePosition, to: sectorObjectsNode)
        }

    }

    func generateWarpGrid() {
        let warpGridEntryShape = SCNTube(innerRadius: 2, outerRadius: 2, height: 220)
        warpGrid.geometry  = warpGridEntryShape
        warpGrid.geometry?.firstMaterial = SCNMaterial()
        let innerTube = SCNMaterial()
        innerTube.diffuse.contents =  UIColor.black
        innerTube.emission.contents =  UIImage(named: "smallestGrid.png")
        warpGrid.opacity = 0.25
        let outerTube = SCNMaterial()
        outerTube.emission.contents =  UIImage(named: "smallestGrid.png")
        outerTube.diffuse.contents = UIColor.black
        let endOne = SCNMaterial()
        endOne.diffuse.contents =  UIColor.blue
        let endTwo = SCNMaterial()
        endTwo.diffuse.contents =  UIColor.purple
        warpGrid.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        warpGrid.physicsBody?.isAffectedByGravity = false
        warpGrid.physicsBody?.applyForce(SCNVector3Make(0, 0, 35), asImpulse: true)
        warpGrid.physicsBody?.friction = 0
        warpGrid.physicsBody?.categoryBitMask = 0b00000010
        warpGrid.physicsBody?.contactTestBitMask = 0b00000000
        warpGrid.name = "warpGrid"

        //warpGrid.geometry?.firstMaterial?.isDoubleSided = true
        warpGrid.geometry?.materials = [outerTube, innerTube, endOne, endTwo]
        // warpGrid.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.position = SCNVector3Make(0, 0, -300)
        warpGrid.scale = SCNVector3Make(1, 1, 1)
        warpGrid.opacity = 0
        scene.rootNode.addChildNode(warpGrid)

    }
    func performWarp() {
        prepWarpEngines()
		warpEngineSound.play()
        generateWarpGrid()

        // WARP!
        let pov = scnView.pointOfView!

        let adjustCamera = SCNAction.run { _ in

			self.setSpeed(30)
            DispatchQueue.main.async {
			self.stepperSpeed.value = 9
            }
			self.warpGrid.opacity = 1
            self.warpGrid.physicsBody?.applyForce(SCNVector3Make(0, 0, 55), asImpulse: true)
			//pov.camera?.motionBlurIntensity = 1.0
        }

		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.0
        pov.runAction(adjustCamera)

        SCNTransaction.commit()

    }

    func turnShip() {
        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(1, 0, 0), by: CGFloat(self.yThrust))
        self.rotate(self.sectorObjectsNode, around: SCNVector3Make(0, 1, 0), by: CGFloat(self.xThrust))

    }
    func enterSector() {
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

    // MARK: - Utility functions

    func notYetImplemented(_ command: String) {
        print("\(command) not yet implemented")

    }

    func cleanSceneAndUpdateSectorNodeObjects() {
        scene.rootNode.enumerateChildNodes({thisNode, _ in

			// remove torpedoes - refactor to be time since torpedo launched

            if (thisNode.name == "torpedo") {
                let thisTorp = thisNode as! Torpedo
                thisTorp.decay()
            }
			// remove explosions - refactor to provide timer for each explosion

            if (thisNode.name == "explosionNode") {
                let thisExplosion = thisNode as! ShipExplosion
                var actualExplosionPosition = scene.rootNode.convertPosition(thisNode.position, from: sectorObjectsNode)
                actualExplosionPosition.z += Float(ship.currentSpeed)/10
                thisExplosion.position = sectorObjectsNode.convertPosition(actualExplosionPosition, from: scene.rootNode)

                thisExplosion.update()

				if thisExplosion.age > 300 {
					thisNode.removeFromParentNode()
					explosionDuration = 0
				}
            }
            if (thisNode.name == "drone") {
                let thisDrone = thisNode as! HumonShip
                thisDrone.maneuver()
            }

			// remove warpgrid - refactor to be time since warpgrid
            if ((thisNode.presentation.position.z > 110) && (thisNode.name == "warpGrid")) {
				SCNTransaction.animationDuration = 0
				SCNTransaction.begin()
				thisNode.opacity = 0
				SCNTransaction.commit()
            }
       })

}

    func countNodes() {
        var numberofNodes = 0

        scene.rootNode.enumerateChildNodes { (_, _) -> Void in
            numberofNodes = numberofNodes + 1
        }
        print("number of live nodes:\(numberofNodes)")

    }

    func numberofShotsOnscreen() -> Int {
    var numberOfShots = 0

        scene.rootNode.enumerateChildNodes({ (child, _) in
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
            let x = sin(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement
            let y =  cos(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement
            self.thetaDisplay.text = "THETA: \(self.sectorObjectsNode.rotation.x)"
            self.phiDisplay.text = "PHI: \(self.sectorObjectsNode.rotation.y)"
            self.velocityDisplay.text = "SHIP VELOCITY - \(self.ship.currentSpeed) Metrons/Centon"
            self.xThrustLabel.text = "X Thrust - \(x)"
            self.yThrustLabel.text = "Y Thrust - \(y)"
            if let drone = self.enemyDrone {
                self.targetDistanceDisplay.text = "DISTANCE TO TARGET - \(self.distanceBetweenPoints(first: drone.position, second: self.cameraNode.position))"
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
