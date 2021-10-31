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
//import MultipeerConnectivity
import GameController
//import CoreMotion

class ZylonGameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    let rankArray = ["ZYLON HERO", "SPACE ACE", "WARRIOR", "CAPTAIN", "STAR COMMANDER", "COMMANDER", "LIEUTENANT", "PILOT", "ENSIGN", "NOVICE", "ROOKIE", "GARBAGE SCOW CAPTAIN", "GALACTIC COOK"]

    //  Multipeer
   // var myMCController = MCController.sharedInstance

    // MARK: - Game Settings
    var gameSettings = getSettings()
    var gameOver = false
    var difficultyScalar: Int {
        switch gameSettings.difficulty {
        case .Novice:
            return 1
        case .Pilot:
            return 2
        case .Commander:
            return 3
        case .Warrior:
            return 4
        case .Lord:
            return 5
        }

    }

    // MARK: - Generic iOS

    override var prefersStatusBarHidden: Bool {
        return true
    }
    // TODO: make gamestate a single codable object

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
    let galacticDisplay = GalacticMapDisplay()
    let scoutTemplate = HumonShip(shipType: .scout)
    let fighterTemplate = HumonShip(shipType: .fighter)
    let destroyerTemplate = HumonShip(shipType: .destroyer)

    let zylonStation = ZylonStation() // preload station
    var forwardCameraNode = SCNNode()
    var rearCameraNode = SCNNode()
    var sectorScanCameraNode = SCNNode()

    let warpGrid = SCNNode()
    let rotateSpeed = 0.5
    var zylonShields = SCNNode()

    var alphaQuadrant: SCNNode { return (galacticDisplay.map.rootNode.childNode(withName: "ALPHA", recursively: true))! }
    var betaQuadrant: SCNNode { return (galacticDisplay.map.rootNode.childNode(withName: "BETA", recursively: true))! }
    var gammaQuadrant: SCNNode { return (galacticDisplay.map.rootNode.childNode(withName: "GAMMA", recursively: true))! }
    var deltaQuadrant: SCNNode { return (galacticDisplay.map.rootNode.childNode(withName: "DELTA", recursively: true))! }
    var rotationNode: SCNNode { return  (galacticDisplay.map.rootNode.childNode(withName: "rotateNode", recursively: true))! }
    var internalRotationNode: SCNNode { return  (galacticDisplay.map.rootNode.childNode(withName: "internalRot", recursively: true))! }
    var galacticSlider = UISlider()

    var currentRankIndex: Int {return 0}

    var enemiesArray: [ShipType]? { return galaxyModel.map[ship.currentSectorNumber].enemyTypes }

    // MARK: - GameState Enums & Structs

    enum ViewMode: Int {
        case foreView
        case aftView
        case galacticMap
    }

    // MARK: - GameState Variables

    var viewMode = ViewMode.foreView
    var currentExplosionParticleSystem: SCNParticleSystem?
    var starSprites = [SCNNode]() // array of stars to make updating them each frame easy
    var attractMode = true
    var galaxyModel: GalaxyMapModel!  // <--- Stupid swift /iOS lifecycle stuff. Defined at viewWillDisplay
    var enemyShipsInSector = [HumonShip]()
    var enemyShipCountInSector: Int {
        return enemyShipsInSector.count
    }

    var ship = ZylonShip()
    var shipCurrrentSectorGrid: SectorGrid {
        return self.galaxyModel.map[ship.currentSectorNumber]
    }
    var targetSectorGrid: SectorGrid {
        return self.galaxyModel.map[ship.targetSectorNumber]
    }

	var shipHud: HUD!
    var classicMap: ClassicMap!
    var zylonScanner = Scanner()

    let divider: Float = 100.0
    var xThrust: Float { return Float(cos(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}
    var yThrust: Float { return Float(sin(self.joystickControl.angle.degreesToRadians) * self.joystickControl.displacement)/divider}

    var sectorObjectsToBeRemoved = [SCNNode]()

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
    let kohai = Kohai()

    //var motionManager: CMMotionManager!

    // Misc Variables
    var currentPhoton = 0
    var numberOfZylonShotsOnscreen = 0
    var numberOfHumanShotsOnscreen = 0

    // gesture variables
    var currentMapAngleZ =  Float.pi
    var currentMapAngleX: Float = 0.0
    var currentMapZoom: Float = 1.0

    // MARK: - IBOutlets

    @IBOutlet weak var threeDToggle: UIButton!
    @IBOutlet weak var sectorStack: UIStackView!
    @IBOutlet weak var speedStack: UIStackView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var spaceScnView: SCNView!
    @IBOutlet weak var mapScnView: SCNView!
    @IBOutlet weak var galacticStack: UIStackView!
    @IBOutlet weak var commandStack: UIStackView!
    @IBOutlet weak var joystickControl: JoyStickView!
    @IBOutlet weak var tacticalDisplay: UIView!
	@IBOutlet weak var currentSpeedDisplay: UILabel!

    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var phiDisplay: UILabel!
    @IBOutlet weak var thetaDisplay: UILabel!
    @IBOutlet weak var enemiesInSectorDisplay: UILabel!
    @IBOutlet weak var targetDistanceDisplay: UILabel!
    @IBOutlet weak var shieldsDisplay: UILabel!
    @IBOutlet weak var shipEnergyDisplay: UILabel!
    @IBOutlet weak var shipSectorLabel: UILabel!
    @IBOutlet weak var targetSectorLabel: UILabel!
    @IBOutlet weak var sliderContainerView: UIView!

    @IBOutlet weak var telemetryView: TelemetryPlayer!

//    func NewOverlayPos(node: SCNNode) -> CGPoint {
//        
//        let worldposition = node.worldPosition
//        
////        let projectedOrigin = scnView.projectPoint(SCNVector3Zero)
////        let vp = gestureRecognizer.locationInView(scnView)
////        let vpWithZ = SCNVector3(x: vp.x, y: vp.y, z: projectedOrigin.z)
////        let worldPoint = gameView.unprojectPoint(vpWithZ)
//    }

    // MARK: - IBActions

    // Command Stack

    @IBOutlet weak var pausedStack: UIStackView!

    @IBAction func pauseGame(_ sender: UIButton) {
        devLog("pauseGame")
        if let paused = self.scnView.scene?.isPaused {
            self.scnView.scene?.isPaused = !paused
            pausedStack.isHidden = paused
            devLog("paused state: \(!paused)")
        }

    }

    @IBAction func toggleTacticalDisplay(_ sender: Any) {
        if ship.isCurrentlyinWarp {
            computerBeepSound("torpedo_fail")
        } else {
        computerBeepSound("beep")
        ship.tacticalDisplayEngaged = !ship.tacticalDisplayEngaged
        }
    }

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
    @IBAction func toggleGalacticMap(_ sender: Any) {
        computerBeepSound("beep")
        if self.viewMode == .galacticMap {
            self.viewMode = .foreView
        } else {
            self.updateGalacticMap()
            self.viewMode = .galacticMap

        }
    }

    @IBAction func settings(_ sender: Any) {
        devLog("settings")
    }
    @IBAction func restartGame(_ sender: Any) {
        devLog("restartGame")
        engineSound.stop()
        func gotoMain(alwaysTrue: Bool) {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "mainMenu")
            vc.modalPresentationStyle = .fullScreen
            engineSound.stop()
            self.present(vc, animated: false, completion: nil)
        }

        UIView.animate(withDuration: 2.0, animations: {
            self.view.alpha = 0.0
        }, completion: gotoMain(alwaysTrue:))

    }

    @IBAction func galacticSlide(_ sender: UISlider) {
        self.ship.targetSectorNumber = Int(sender.value)
        //        let sectorString = "\(self.ship.targetSectorNumber+1)"
        //        let targetGrid = galacticDisplay.map.rootNode.childNode(withName: sectorString, recursively: true)

        galacticDisplay.setNewTargetGrid(number: ship.targetSectorNumber, color: UIColor.red)
        galacticDisplay.setNewShipCurrentGrid(number: ship.currentSectorNumber, color: UIColor.white)
        classicMap.setNewTargetGrid(number: ship.targetSectorNumber, color: UIColor.red)

        self.shipSectorLabel.text = "Ship Sector: \(self.shipCurrrentSectorGrid.quadrant) \(self.shipCurrrentSectorGrid.quadrantNumber)"
        self.targetSectorLabel.text = "Target Sector: \(self.targetSectorGrid.quadrant) \(self.targetSectorGrid.quadrantNumber)"

    }

 // Galactic Stack
    @IBAction func DToggle(_ sender: UIButton) {
        if galacticDisplay.threeDMode == true {
            galacticDisplay.threeDMode = false
            self.threeDToggle.setTitle("2D", for: .normal)
        } else {
            galacticDisplay.threeDMode = true
            self.threeDToggle.setTitle("3D", for: .normal)

        }
    }

    // MARK: - CATEGORIZE THESE

    func envSound(_ soundString: String) {
        if let soundURL = Bundle.main.url(forResource: soundString, withExtension: "m4a") { do {
            try beepsound =  AVAudioPlayer(contentsOf: soundURL)
        } catch {
            devLog("beepsound failed")
            }
            beepsound.volume = 0.5
            beepsound.play()
        }
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
        if numberOfZylonShotsOnscreen < Constants.maxTorpedoes-2 && !self.aButtonJustPressed {
            ship.energyStore -= 5 * self.difficultyScalar
            let torpedoNode = Torpedo(designatedTorpType: .zylon)
            let photonSoundArray = [photonSound1, photonSound2, photonSound3, photonSound4]
            let currentplayer = photonSoundArray[currentPhoton]
           // let offset: Float = 4
            mainGameScene.rootNode.addChildNode(torpedoNode)
           // let driftAmount: Float = 2
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
        if numberOfZylonShotsOnscreen < Constants.maxTorpedoes && !self.aButtonJustPressed && !gameOver {
            ship.energyStore -= 5 * self.difficultyScalar
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

    func beginRepairBeamFrom(starbase: ZylonStation) {
        starbase.beginRepair()
    }

@IBAction func fireTorpedo(_ sender: UIButton) {
    if self.viewMode == .foreView { fireTorp() } else {
        if self.viewMode == .aftView { fireAftTorp() }}
    }

	@IBOutlet weak var stepperSpeed: UIStepper!

    fileprivate func populateSector() {
        switch self.shipCurrrentSectorGrid.sectorType {
        case .starbase:
            ship.currentSpeed = 0
            self.spawnStarbase()
            telemetryView.text = ""
            telemetryView.isHidden = false
            telemetryView.alpha = 1.0
            delayWithSeconds(2.0, completion: {
                self.telemetryView.writeMessage(message: "Standby for repairs")
            })
            delayWithSeconds(3.25, completion: {
                self.beginRepairBeamFrom(starbase: self.zylonStation)
            })

            if !self.gameOver && self.shipCurrrentSectorGrid.numberOfSectorObjects > 0 {
            delayWithSeconds(8, completion: {
                if !self.gameOver {
                self.ship.repair()
                self.shipHud.deactivateAlert()
                if self.galaxyModel.map[self.ship.currentSectorNumber].sectorType == .empty {
                    self.kohai.computerBeepSound("alert")
                    self.telemetryView.writeMessage(message: "Repairs aborted")
                } else {
                self.kohai.computerBeepSound("refuelComplete")
                self.telemetryView.writeMessage(message: "Repairs completed")
                }
                delayWithSeconds(4, completion: {self.telemetryView.fadeout()
                    self.zylonStation.completeRepair()
                })
                } else {
                    self.telemetryView.abort()
                    self.shipHud.deactivateAlert()
                }
            })
            } else {
                self.telemetryView.abort()
            }

        case .enemy,
             .enemy2,
             .enemy3:
            ship.currentSpeed = 2
           // self.spawnEnemies(number: self.shipCurrrentSectorGrid.numberOfSectorObjects)
            if let  enemies = enemiesArray { self.spawnEnemies(ofTypes: enemies) }
            devLog("ENEMY SECTOR \(self.shipCurrrentSectorGrid.quadrant) \(self.shipCurrrentSectorGrid.quadrantNumber) type: \(self.shipCurrrentSectorGrid.sectorType) spawning \(self.shipCurrrentSectorGrid.numberOfSectorObjects) enemies")
            //self.shipHud.soundSectorAlarm()
        case .empty:
            ship.currentSpeed = 3
            devLog("Empty Sector")
        }
    }

    func enemyAlert() {
        computerBeepSound("enemyAlert")
    }
    func spawnStarbase() {
        zylonStation.worldPosition = SCNVector3Make(0, 0, -50)
        zylonStation.scale = SCNVector3Make(0.1, 0.1, 0.1)
        zylonStation.isHidden = false
        let constraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
        constraint.isGimbalLockEnabled = true
        zylonStation.constraints = [constraint]
        flyIn(node: zylonStation, toScale: 0.5)
        devLog("starbase spawned at position")
        devLog(zylonStation.worldPosition)

    }

    func flyIn(node: SectorObject, toScale: Float) {
        let panim = SCNAction.scale(to: CGFloat(toScale), duration: 1.5)
        node.runAction(panim)
    }
//    func spawnEnemy() {
//        let enemyDrone = HumonShip()
//        enemyDrone.scale = SCNVector3Make(0.1, 0.1, 0.1)
//
//        let constraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
//        constraint.isGimbalLockEnabled = true
//        enemyDrone.constraints = [constraint]
//        enemyDrone.position = self.mainGameScene.rootNode.convertPosition((enemyDrone.worldPosition), to: self.sectorObjectsNode)
//        self.sectorObjectsNode.addChildNode(enemyDrone)
//        flyIn(node: enemyDrone, toScale: 1.0)
//    }

    func spawnEnemy(type: ShipType ) {
        let enemyDrone = HumonShip(shipType: type.self)
         enemyDrone.scale = SCNVector3Make(0.1, 0.1, 0.1)

         let constraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
         constraint.isGimbalLockEnabled = true
         enemyDrone.constraints = [constraint]
         enemyDrone.position = self.mainGameScene.rootNode.convertPosition((enemyDrone.worldPosition), to: self.sectorObjectsNode)
         self.sectorObjectsNode.addChildNode(enemyDrone)
         flyIn(node: enemyDrone, toScale: 1.0)
     }

    func spawnEnemies(ofTypes: [ShipType]) {
        devLog("spawnEnemies(ofTypes:")
           for  type in ofTypes {
                devLog(type)
               spawnEnemy(type: type)
           }
       }

    @IBAction func gridWarp(_ sender: UIButton) {
        if !ship.isCurrentlyinWarp && !gameOver && ship.targetSectorNumber != ship.currentSectorNumber {
            let speedBeforeWarp = ship.currentSpeed
            let tacticalWasEngaged = ship.tacticalDisplayEngaged
            ship.tacticalDisplayEngaged = false
            let targetAtWarp = ship.targetSectorNumber
            performWarp()
            switch galaxyModel.map[ship.targetSectorNumber].sectorType {
            case .starbase:
                self.scnView.prepare(zylonStation, shouldAbortBlock: nil)
            case .enemy:
                self.scnView.prepare(zylonStation, shouldAbortBlock: nil)
            default:
                devLog("Empty Sector")
            }

            let deadlineTime = DispatchTime.now() + .seconds(6)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                if !self.gameOver {
                self.setSpeed(speedBeforeWarp)
                self.forwardCameraNode.camera?.motionBlurIntensity = 0
                self.ship.isCurrentlyinWarp = false
                self.ship.tacticalDisplayEngaged = tacticalWasEngaged
                self.ship.currentSectorNumber = targetAtWarp
                self.enterSector(sectorNumber: targetAtWarp)
                self.ship.targetSectorNumber = randIntRange(lower: 0, upper: 126)
                    self.galacticDisplay.updateDisplay(galaxyModel: self.galaxyModel, shipSector: self.ship.currentSectorNumber, targetSector: self.ship.targetSectorNumber)
                    self.classicMap.updateDisplay(galaxyModel: self.galaxyModel, shipSector: self.ship.currentSectorNumber, targetSector: self.ship.targetSectorNumber)
                }
            }
            let spawnDeadline = DispatchTime.now() + .seconds(7)
            DispatchQueue.main.asyncAfter(deadline: spawnDeadline) {
                self.updateGalacticMap()

                self.populateSector()
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

    @IBAction func alpha(_ sender: Any) {
        computerBeepSound("beep")
//        let action = SCNAction.rotateTo(x: 0.1, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
//            rotationNode.runAction(action)
            classicMap.highlightAlpha()
            alphaQuadrant.opacity = 1.0
            betaQuadrant.opacity = Constants.fadedMapTransparency
            gammaQuadrant.opacity = Constants.fadedMapTransparency
            deltaQuadrant.opacity = Constants.fadedMapTransparency
            kohai.speak("AlphaSector")
            galacticSlider.minimumValue = 0
            galacticSlider.maximumValue = 31
            ship.targetSectorNumber = 16
        self.targetSectorLabel.text = "Target Sector: \(self.targetSectorGrid.quadrant) \(self.targetSectorGrid.quadrantNumber)"
        classicMap.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: ship.targetSectorNumber)

    }
    @IBAction func beta(_ sender: Any) {
        computerBeepSound("beep")
        classicMap.highlightBeta()
//            let action = SCNAction.rotateTo(x: 0, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
//            rotationNode.runAction(action)
        alphaQuadrant.opacity = Constants.fadedMapTransparency
        betaQuadrant.opacity = 1.0
        gammaQuadrant.opacity = Constants.fadedMapTransparency
        deltaQuadrant.opacity = Constants.fadedMapTransparency
        kohai.speak(("BetaSector"))
        galacticSlider.minimumValue = 32
        galacticSlider.maximumValue = 63
        ship.targetSectorNumber = 48
        self.targetSectorLabel.text = "Target Sector: \(self.targetSectorGrid.quadrant) \(self.targetSectorGrid.quadrantNumber)"
        classicMap.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: ship.targetSectorNumber)

    }
    @IBAction func gamma(_ sender: Any) {
        computerBeepSound("beep")

//        let action = SCNAction.rotateTo(x: -0.1, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
//        rotationNode.runAction(action)
        alphaQuadrant.opacity = Constants.fadedMapTransparency
        betaQuadrant.opacity = Constants.fadedMapTransparency
        gammaQuadrant.opacity = 1.0
        deltaQuadrant.opacity = Constants.fadedMapTransparency
        kohai.speak("GammaSector")
        galacticSlider.minimumValue = 64
        galacticSlider.maximumValue = 95
        ship.targetSectorNumber = 80
        classicMap.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: ship.targetSectorNumber)

    }
    @IBAction func delta(_ sender: Any) {
        computerBeepSound("beep")

//        let action = SCNAction.rotateTo(x: -0.16, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
//        rotationNode.runAction(action)
        alphaQuadrant.opacity = Constants.fadedMapTransparency
        betaQuadrant.opacity = Constants.fadedMapTransparency
        gammaQuadrant.opacity = Constants.fadedMapTransparency
        deltaQuadrant.opacity = 1.0
        kohai.speak("DeltaSector")
        galacticSlider.minimumValue = 96
        galacticSlider.maximumValue = 127
        ship.targetSectorNumber = 112
        self.targetSectorLabel.text = "Target Sector: \(self.targetSectorGrid.quadrant) \(self.targetSectorGrid.quadrantNumber)"
        classicMap.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: ship.targetSectorNumber)

    }

    @IBAction func allQuads(_ sender: Any) {
//        let action = SCNAction.rotateTo(x: -0.5, y: 0, z: 3.1, duration: rotateSpeed, usesShortestUnitArc: true)
//        rotationNode.runAction(action)
        kohai.speak("galacticMap")
        alphaQuadrant.opacity = 1.0
        betaQuadrant.opacity = 1.0
        gammaQuadrant.opacity = 1.0
        deltaQuadrant.opacity = 1.0
        galacticSlider.minimumValue = 0
        galacticSlider.maximumValue = 127

    }

    // MARK: - SETUP

    override func viewWillAppear(_ animated: Bool) {
        self.galaxyModel = GalaxyMapModel(difficulty: difficultyScalar)
        self.galacticSlider.isHidden = true
        self.restartButton.isHidden = true
        self.view.alpha = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, animations: {self.view.alpha = 1})
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

//      myMCController.setup()
//      myMCController.myCommandDelegate = self

        setupView()
        setupScene()
        setupShip()

        shipHud.parentScene = self

    }

    func setupView() {
        scnView = spaceScnView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        scnView.backgroundColor = UIColor.black
        joystickControl.movable = true
        joystickControl.baseAlpha = 0.3
        joystickControl.alpha = 0.2

        // rotate slider and constrain it to the container view
        galacticSlider.minimumValue = 0
        galacticSlider.maximumValue = 127
        galacticSlider.isUserInteractionEnabled = true
        galacticSlider.addTarget(self, action: #selector(galacticSlide(_:)), for: UIControl.Event.valueChanged)
        galacticSlider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.addSubview(galacticSlider)
        galacticSlider.tintColor = .blue
        galacticSlider.thumbTintColor = .blue
        galacticSlider.maximumTrackTintColor = .blue
//        self.galacticSlider.center = self.sliderContainerView.center
        galacticSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Float.pi/2))
            var constraints = [NSLayoutConstraint]()
        constraints.append(galacticSlider.widthAnchor.constraint(equalTo: sliderContainerView.heightAnchor))
        constraints.append(galacticSlider.centerYAnchor.constraint(equalTo: sliderContainerView.centerYAnchor))
        constraints.append(galacticSlider.centerXAnchor.constraint(equalTo: sliderContainerView.centerXAnchor))
        constraints.append(galacticSlider.centerYAnchor.constraint(equalTo: sliderContainerView.centerYAnchor))

       // self.galacticSlider.heightAnchor.constraint(equalTo: self.sliderContainerView.widthAnchor)
        NSLayoutConstraint.activate(constraints)
    }

    func setupScene() {

        //prepare game elements for later display

        scnView.scene = mainGameScene
        createStars()
        generateWarpGrid()
        self.scnView.prepare(fighterTemplate, shouldAbortBlock: nil)
        self.scnView.prepare(scoutTemplate, shouldAbortBlock: nil)
        self.scnView.prepare(destroyerTemplate, shouldAbortBlock: nil)

        // setup HUD

        devLog("screen.widthRatio:\(screen.widthRatio)")
        devLog("screen.heightRatio:\(screen.heightRatio)")

        classicMap = ClassicMap(size: self.view.bounds.size)

        shipHud = HUD(size: self.view.bounds.size)

        scnView.overlaySKScene = shipHud
        mapScnView.overlaySKScene = classicMap
        mapScnView.overlaySKScene?.scaleMode = .aspectFit
        mainGameScene.physicsWorld.contactDelegate = self
        scnView.delegate = self

        // setup scanner & galactic map views
        setupGalacticMapView()
        addScanner()

        // prepare sounds
        setupPhotonSounds()
        setupGridWarpEngineSounds()
        playEngineSound(volume: 1)

        self.sectorObjectsNode.addChildNode(zylonStation) // to avoid loading, we keep the station in memory at all times
        zylonStation.isHidden = true

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

    }

    func setupPhotonSounds() {
        var soundURL: URL?
        currentPhoton = 0
        soundURL = Bundle.main.url(forResource: "photon_sound", withExtension: "m4a")
        do { try photonSound1 = AVAudioPlayer(contentsOf: soundURL!)} catch { devLog("photon player 1 ailed")}
        do { try photonSound2 = AVAudioPlayer(contentsOf: soundURL!)} catch { devLog("photon player 2 failed")}
        do { try photonSound3 = AVAudioPlayer(contentsOf: soundURL!)} catch { devLog("photon player 3 failed")}
        do { try photonSound4 = AVAudioPlayer(contentsOf: soundURL!)} catch { devLog("photon player 4 failed")}

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
            let randX = randRange(lower: -50, upper: 50)
            let randY = randRange(lower: -50, upper: 50)
            let randZ = randRange(lower: -500, upper: 500)
            let sphere = SCNSphere(radius: 0.25)
            let starSprite = SCNNode()
            starSprite.geometry  = sphere
            starSprite.position = SCNVector3Make(randX, randY, randZ)
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
        zylonHull.physicsBody?.contactTestBitMask =  ObjectCategories.zylonShip
        zylonHull.physicsBody?.categoryBitMask =  ObjectCategories.zylonShip

        mainGameScene.rootNode.addChildNode(zylonHull)

        sectorScanCameraNode.camera = SCNCamera()
        sectorScanCameraNode.position = SCNVector3(x: 0, y: 200, z: 0)
        let cameraconstraint = SCNLookAtConstraint(target: mainGameScene.rootNode)
        cameraconstraint.isEnabled = true
        sectorScanCameraNode.constraints = [cameraconstraint]
        sectorScanCameraNode.name = "SectorScanCamera"
        self.ship.addChildNode(sectorScanCameraNode)

        ship.currentSpeed = 2
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
        zylonScanner.position = SCNVector3Make(-2.15, -2.9, -8)
        mainGameScene.rootNode.addChildNode(zylonScanner)
        zylonScanner.isHidden = true
        // start scanBeam
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(2*Float.pi), z: 0, duration: 1.5)
        let perpetualRotation = SCNAction.repeatForever(rotateAction)
        zylonScanner.scanBeam.runAction(perpetualRotation)
    }

    func setupGalacticMapView() {

        let transition = SKTransition.fade(withDuration: 0)
        mapScnView.present(galacticDisplay.map, with: transition, incomingPointOfView: galacticDisplay.map.rootNode.childNode(withName: "gCam", recursively: true), completionHandler: {
            self.mapScnView.allowsCameraControl = false
            })
        let myPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mapPan(_:)))
        let myZoomRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(mapZoom(_:)))
        let myTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTap(_:)))
        mapScnView.addGestureRecognizer(myPanRecognizer)
        mapScnView.addGestureRecognizer(myZoomRecognizer)
        mapScnView.addGestureRecognizer(myTapRecognizer)

    }

    // MARK: - Map rotator & Zoomer

    @objc func mapTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
        let location = gesture.location(in: mapScnView)
        let hitresults = mapScnView.hitTest(location, options: nil)
            devLog("hitResults:\(hitresults)")
        if !hitresults.isEmpty {
            var tappedNode: SCNNode?
            // test if it's a grid element

            for result in hitresults {
            for x in 0...127 {
                let sectorString = "\(x)"
                if result.node.name == sectorString {
                    tappedNode =  hitresults.first?.node
                    devLog("tapped Node:\(String(describing: tappedNode?.name))")
                    //print("galaxyModel.map[\(x)].sectorType:", galaxyModel.map[x].sectorType)
                    if galaxyModel.map[x].sectorType != .empty {
                    galacticDisplay.setNewTargetGrid(number: x, color: UIColor.red)

                    devLog("Node Highlighted")
                    }
                }
            }
            }
        }

        }
    }

    @objc func mapPan(_ gesture: UIPanGestureRecognizer) {

        let translation = gesture.translation(in: gesture.view)
        var newAngleZ = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleZ += currentMapAngleZ

        var newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
        newAngleX += currentMapAngleX
        if newAngleX > 0.2 {newAngleX = 0.2} else if newAngleX < -0.4 {newAngleX = -0.4}

        internalRotationNode.eulerAngles.z = newAngleZ
        rotationNode.eulerAngles.x = newAngleX

        if gesture.state == .ended {
           currentMapAngleZ = newAngleZ
           currentMapAngleX = newAngleX
        }

    }

    @objc func mapZoom(_ gesture: UIPinchGestureRecognizer) {
        var newZoom = gesture.scale
        if newZoom > 1.2 {newZoom = 1.2} else if newZoom < 0.75 {newZoom = 0.75}
        galacticDisplay.rotationNode.scale = SCNVector3(newZoom, newZoom, newZoom)
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
        if newSpeed == 0 {
			engineSound.setVolume(0, fadeDuration: 1.0)
        }
        if newSpeed == 1 {
			engineSound.setVolume(1, fadeDuration: 1.0)
		}
    }

    // MARK: - Game Event functions
    func humonShipHit(nodeA: SCNNode, nodeB: SCNNode) {
        boom(atNode: nodeA)
        galaxyModel.decrementEnemyCount(sector: ship.currentSectorNumber)

    }

    func zylonShipHitBy(node: SCNNode) {
        devLog("Zylon Ship hit by \(node.description)")

        // we should animate removal of node which hit ship, but for now just remove it.
        // if no shields, special explosion for zylonShipHit

        if !ship.shieldsAreUp {
            boomAndLose(atNode: node, cause: "Prototype defense ship destroyed by Humon Fire")
            return
        }

        if let removeMe = node as? SectorObject {
        markSectorObjectToBeRemoved(object: removeMe)
        }

        if ship.shieldsAreUp && ship.shieldStrength > -1 {

            if difficultyScalar>1 {
            ship.energyStore -= 5 * self.difficultyScalar
            }
            self.environmentSound("forcefieldHit")
            shipHud.shieldFlash()

            //let overlayPos = self.overlayPos(node: node) // screen coordinates of hit in UIVIew

//            DispatchQueue.main.async {
//                let hitplane = SCNPlane(width: 1, height: 1)
//                hitplane.firstMaterial?.diffuse.contents = UIImage(named: "shieldHit")
//                let hitPlaneNode = SCNNode(geometry: hitplane)
//                hitPlaneNode.opacity = 0.5
//                hitPlaneNode.position = node.presentation.position
//
//                self.mainGameScene.rootNode.addChildNode(hitPlaneNode)
//                let fadeout = SCNAction.fadeOut(duration: 1.0)
//                hitPlaneNode.runAction(fadeout)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                hitPlaneNode.removeFromParentNode()
//                }
//            }

           // let overlaySpritePOS = shipHud.convertPoint(fromView: overlayPos) //
           //shipHud.shieldHit(location: overlaySpritePOS)

            //decrement shield strength, and then determine if shields have held
            ship.shieldStrength = ship.shieldStrength - 5 * self.difficultyScalar
            if ship.shieldStrength>0 {
            devLog("SHIELDS HAVE HELD! Current Shield Strenth: \(ship.shieldStrength)")
            } else {
                self.shipHud.activateAlert(message: "SHIELD FAILURE!")
                ship.takeDamage()

            }

        } else {
            devLog("hullHit sound because sheilds are down")

            self.environmentSound("Raw Hull Hit")
            ship.takeDamage()
        }
    }

    func stationBoom(atNode: SCNNode) {
        devLog("stationBoom!")

        for _ in 1...8 {
            let randomX = randRange(lower: -10, upper: 15)
            let randomY = randRange(lower: -10, upper: 10)
            let randomZ = randRange(lower: -10, upper: 10)
            let newPOS = SCNVector3(x: atNode.presentation.position.x + randomX, y: atNode.presentation.position.y + randomY, z: atNode.presentation.position.z + randomZ)
            let explosionNode = StationExplosion()
            explosionNode.scale = SCNVector3(2, 2, 2)
            explosionNode.position = atNode.presentation.position
            self.sectorObjectsNode.addChildNode(explosionNode)
        DispatchQueue.main.async {
            let explosionNode = StationExplosion()
            explosionNode.position = newPOS
            self.sectorObjectsNode.addChildNode(explosionNode)
            self.explosionSound()
        }
        }
            galaxyModel.decrementEnemyCount(sector: ship.currentSectorNumber)
            galacticDisplay.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: self.ship.targetSectorNumber)
            self.classicMap.updateDisplay(galaxyModel: self.galaxyModel, shipSector: self.ship.currentSectorNumber, targetSector: self.ship.targetSectorNumber)

        delayWithSeconds(1.7, completion: {self.kohai.speak("badIdea")})

    }
    func boom(atNode: SCNNode) {
        devLog("BOOM!")
        DispatchQueue.main.async {
            let explosionNode = ShipExplosion()
            explosionNode.position = atNode.presentation.position
            self.sectorObjectsNode.addChildNode(explosionNode)
            self.explosionSound()
        }

    }
    func zylonSurvivableBoom(atNode: SCNNode) {
        devLog("SHIELDBOOM!")
        DispatchQueue.main.async {
            let explosionNode = ShieldExplosion()
            explosionNode.position = atNode.presentation.position
            self.sectorObjectsNode.addChildNode(explosionNode)
            self.explosionSound()
        }

    }

    func boomAndLose(atNode: SCNNode, cause: String) {
        removeMarkedSectorObjects()
        zylonScanner.isHidden = true
        zylonScanner.scanBeam.removeAllActions()
        viewMode = .foreView
        finalExplosionSound()
        gameOver = true
        shipHud.finalFlash()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.endGame(cause)
        }

    }

    func justWin(atNode: SCNNode, cause: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.gameOver = true
        })
        shipHud.finalFlash()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            self.endGame(cause)
        }

    }

    func checkForGameEnd() {
        let stationGrids = galaxyModel.map.filter {$0.sectorType == .starbase}
        let enemyGrids = galaxyModel.map.filter {$0.sectorType == .enemy }
        if stationGrids.count == 0 {
            boomAndLose(atNode: ship, cause: "All is lost. Zylon outposts destroyed by Humon invaders")
        }

        if enemyGrids.count == 0 {
            justWin(atNode: ship, cause: "Victory is ours. The Humons have been vanquished")
        }
        }

    func endGame(_ cause: String) {
        engineSound.stop()
        removeAllTorps()
        self.telemetryView.setupTelemetryAudioPlayer()
        delayWithSeconds(1, completion: {
            self.telemetryView.text = ""
            self.telemetryView.isHidden = false
            let newrank: Float = self.galaxyModel.occupiedSectorRatio*Float(self.rankArray.count)
            var rankIndex = Int(newrank)
            if self.difficultyScalar < 3 && rankIndex < self.rankArray.count-1 { rankIndex += 1 }

            devLog("occupiedSectorRatio: \(self.galaxyModel.occupiedSectorRatio)")
            devLog("rankIndex: \(rankIndex)")
            let rank: String =  self.rankArray[rankIndex]
            let message = """
            Zylon Command to all sectors. \(cause)

            Postumous Rank: \(rank)
            """
            self.telemetryView.writeMessage(message: message, speed: 0.05)

        })

        delayWithSeconds(6, completion: {
            self.restartButton.alpha = 0
            self.restartButton.isHidden = false
            self.restartButton.fadeIn()
        })
    }

    func markSectorObjectToBeRemoved(object: SCNNode) {
        self.sectorObjectsToBeRemoved.append(object)
    }

    func updateStars() {
        for star in self.starSprites {
            //if star distance is greater than 400 total
            var starScenePosition: SCNVector3
            starScenePosition = mainGameScene.rootNode.convertPosition(star.position, from: sectorObjectsNode)
            starScenePosition.z += Float(ship.currentSpeed) * Constants.starMoveDivider

            if starScenePosition.z > 400 || starScenePosition.y > 250 || starScenePosition.y < -250 {
                starScenePosition.z = randRange(lower: -600, upper: -400)
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
        warpGrid.physicsBody?.categoryBitMask = ObjectCategories.warpgrids
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

        let energyUsed = abs(ship.currentSectorNumber - ship.targetSectorNumber) * self.difficultyScalar
        ship.energyStore -= energyUsed
        ship.isCurrentlyinWarp = true
        if ship.tacticalDisplayEngaged {
            toggleTacticalDisplay(self)
        }
        self.viewMode = .foreView
        resetWarpgrid()

        self.forwardCameraNode.camera?.wantsHDR = false
        self.forwardCameraNode.camera?.motionBlurIntensity = 1.0

        // WARP!
        SCNTransaction.begin()
     //   SCNTransaction.animationDuration = 1.5
			self.setSpeed(10)
            DispatchQueue.main.async {
			self.stepperSpeed.value = 9
            }

        sectorObjectsNode.enumerateChildNodes({thisNode, _ in
            //remove all ships and torpedoes, and hide the space station
            if thisNode.name == "humonShip" || thisNode.name == "torpedo" {
            markSectorObjectToBeRemoved(object: thisNode)
            }
            zylonStation.isHidden = true
        })

        SCNTransaction.commit()

    }

    func turnShip() {
        if let controllerHardware = mainController?.extendedGamepad {
            let yT = controllerHardware.leftThumbstick.xAxis.value/40
            let xT = controllerHardware.leftThumbstick.yAxis.value/40
            self.rotate(self.sectorObjectsNode, around: Constants.xAxis, by: CGFloat(xT))
            self.rotate(self.sectorObjectsNode, around: Constants.yAxis, by: CGFloat(yT))

        } else {
            self.rotate(self.sectorObjectsNode, around: Constants.xAxis, by: CGFloat(self.xThrust))
            self.rotate(self.sectorObjectsNode, around: Constants.yAxis, by: CGFloat(self.yThrust))

        }

        self.rotate(self.sectorObjectsNode, around: Constants.yAxis, by: CGFloat(self.xThrust))
        self.rotate(self.sectorObjectsNode, around: Constants.yAxis, by: CGFloat(self.yThrust))

    }

    func enterSector(sectorNumber: Int) {

        devLog("Entering sector: \(shipCurrrentSectorGrid.quadrant) \(shipCurrrentSectorGrid.quadrantNumber)")
        devLog("actualSector Number: \(sectorNumber)")

        var audioItems: [AVPlayerItem] = []
        var soundURL = Bundle.main.url(forResource: "entering_sector", withExtension: "m4a")
        let sector = AVPlayerItem(url: soundURL!)
        audioItems.append(sector)

        // quadrant
        let quad = galaxyModel.map[sectorNumber].quadrant
        let quadrantNumber = galaxyModel.map[sectorNumber].quadrantNumber
        soundURL = Bundle.main.url(forResource: quad.rawValue, withExtension: "m4a")
        var item = AVPlayerItem(url: soundURL!)
        audioItems.append(item)

        // x coordinate

        if quadrantNumber < 10 {
            let tensString = numberstrings[0]
            soundURL = Bundle.main.url(forResource: tensString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

            let onesString = numberstrings[quadrantNumber]
             soundURL = Bundle.main.url(forResource: onesString, withExtension: "m4a")
             item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

        } else {
            let tensString = numberstrings[quadrantNumber / 10] //tens digit
            soundURL = Bundle.main.url(forResource: tensString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

            let onesString = numberstrings[quadrantNumber % 10] // remainder
            soundURL = Bundle.main.url(forResource: onesString, withExtension: "m4a")
            item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)

        }
        computerVoice = AVQueuePlayer(items: audioItems)
        computerVoice.volume = 1
        computerVoice.play()
    }

    func updateTactical() {
        if ship.tacticalDisplayEngaged && !ship.isCurrentlyinWarp {
            DispatchQueue.main.async {

            var rotx = self.sectorObjectsNode.eulerAngles.x.radiansToDegrees
            if rotx < 0 || rotx > 360 {
                rotx = abs(rotx.truncatingRemainder(dividingBy: 360))
            }
            var roty = self.sectorObjectsNode.eulerAngles.y.radiansToDegrees
            if roty < 0 || rotx > 360 {
                roty = abs(rotx.truncatingRemainder(dividingBy: 360))
            }

            let roundedX = round(rotx * 100) / 100
            let roundedY = round(roty * 100) / 100

            self.thetaDisplay.text = "Θ: \(roundedX)"
            self.phiDisplay.text = "ɸ: \(roundedY)"

            if self.ship.shieldsAreUp {
                self.shieldsDisplay.text = "Shields: \(self.ship.shieldStrength)%"
            } else {
                self.shieldsDisplay.text = "Shields: DOWN"

            }
            self.shipEnergyDisplay.text = "Energy: \(self.ship.energyStore)"

            self.enemiesInSectorDisplay.text = "Enemies In Sector: \(self.enemyShipCountInSector)"

            if self.enemyShipCountInSector > 0 {
                let drone = self.enemyShipsInSector[0]
                self.targetDistanceDisplay.text = "DISTANCE TO TARGET - \(distanceBetweenPoints(first: drone.position, second: self.forwardCameraNode.position))"
            } else {
                self.targetDistanceDisplay.text = "NO ENEMY TARGETS"
                }
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
                devLog("target sector:\(String(describing: selectedNode.name))")
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
        devLog("\(command) not yet implemented")
        computerBeepSound("torpedo_fail")
    }

    func removeMarkedSectorObjects() {
        for object in sectorObjectsToBeRemoved {
            devLog("Removing sector Object: \(object.description) ")
            object.removeFromParentNode()
        }
        sectorObjectsToBeRemoved.removeAll()
        checkForGameEnd()
    }

    func removeAllTorps() {
        mainGameScene.rootNode.enumerateChildNodes({thisNode, _ in
            if thisNode.name?.range(of: "torpedo") != nil {
                thisNode.presentation.opacity = 0
                devLog("hiding torps")
            }

        })
    }
    func cleanSceneAndUpdateSectorNodeObjects() {
        var localNumberOfZylonShotsOnscreen = 0
        var localNumberOfHumonShotsOnscreen = 0
        enemyShipsInSector.removeAll()
        removeMarkedSectorObjects()

        mainGameScene.rootNode.enumerateChildNodes({thisNode, _ in

			// if this is a torpedo, increment decay and, if a humon torpedo, move it!
            if  thisNode.name?.range(of: "torpedo") != nil {
                let thisTorp = thisNode as! Torpedo
                if thisTorp.presentation.opacity == 0 {
                    DispatchQueue.main.async {
                    self.markSectorObjectToBeRemoved(object: thisTorp)
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

			// if this node is an explosion, update its position and update it for decay
            if thisNode.name == "explosionNode" {
                if let thisExplosion = thisNode as? ShipExplosion {
                    var actualExplosionPosition = mainGameScene.rootNode.convertPosition(thisNode.position, from: sectorObjectsNode)
                    actualExplosionPosition.z += Float(ship.currentSpeed)/10
                    thisExplosion.position = sectorObjectsNode.convertPosition(actualExplosionPosition, from: mainGameScene.rootNode)

                thisExplosion.update()
                // if the explosion is old enough, remove it.
				if thisExplosion.age > 300 {
					markSectorObjectToBeRemoved(object: thisNode)
					explosionDuration = 0
				}
                }
            }

            if thisNode.name == "humonShip" {
                let thisHumonShip = thisNode as! HumonShip
                enemyShipsInSector.append(thisHumonShip)
                let thisShip = thisNode as! HumonShip
                var actualShipPosition = mainGameScene.rootNode.convertPosition(thisNode.position, from: sectorObjectsNode)
                actualShipPosition.z += Float(ship.currentSpeed)/5
                thisShip.position = sectorObjectsNode.convertPosition(actualShipPosition, from: mainGameScene.rootNode)

                thisHumonShip.maneuver()
            }

			// remove warpgrid - refactor to be time since warpgrid
            if (thisNode.worldPosition.z > 130) && (thisNode.name == "warpGrid") {
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
        devLog("Contact!")
        devLog("nodeA: \(String(describing: contact.nodeA.name!))")
        devLog("nodeB: \(String(describing: contact.nodeB.name!))")
        devLog("shield status at time of contact: \(ship.shieldsAreUp)")

        if contact.nodeA.name == "zylonHull" {
            zylonShipHitBy(node: contact.nodeB)
            self.markSectorObjectToBeRemoved(object: contact.nodeB)
            return
            } else {
            if contact.nodeB.name == "zylonHull" {
                    zylonShipHitBy(node: contact.nodeA)
                    self.markSectorObjectToBeRemoved(object: contact.nodeA)
                    return
            } else {
            if  contact.nodeB.name == "zylonStation" {
                        stationBoom(atNode: contact.nodeB)
                        self.markSectorObjectToBeRemoved(object: contact.nodeA)
                        contact.nodeB.isHidden = true
                        telemetryView.abort()
                    } else { if contact.nodeA.name == "zylonStation" {
                stationBoom(atNode: contact.nodeB)
                self.markSectorObjectToBeRemoved(object: contact.nodeB)
                contact.nodeA.isHidden = true
            } else {
        DispatchQueue.main.async {
            self.humonShipHit(nodeA: contact.nodeA, nodeB: contact.nodeB)
            self.markSectorObjectToBeRemoved(object: contact.nodeA)
            self.markSectorObjectToBeRemoved(object: contact.nodeB)
            }
            }

        }
            }
        }
    }

    func updateGalacticMap() {
        galacticDisplay.updateDisplay(galaxyModel: galaxyModel, shipSector: ship.currentSectorNumber, targetSector: ship.targetSectorNumber)
        self.classicMap.updateDisplay(galaxyModel: self.galaxyModel, shipSector: self.ship.currentSectorNumber, targetSector: self.ship.targetSectorNumber)
        self.shipSectorLabel.text = "Ship Sector: \(self.shipCurrrentSectorGrid.quadrant) \(self.shipCurrrentSectorGrid.quadrantNumber)"
        self.targetSectorLabel.text = "Target Sector: \(self.targetSectorGrid.quadrant) \(self.targetSectorGrid.quadrantNumber)"

//
//        for i in 1...128 {
//            let sectorString = "\(i)"
//            let currentGrid = galacticDisplay.map.rootNode.childNode(withName: sectorString, recursively: true)
//
//            for gridElement in currentGrid!.childNodes {
//                gridElement.removeFromParentNode()
//            }
//
//           // devLog("targetGrid: \(currentGrid!.name ?? "") is of type \(galaxyModel.map[i-1].sectorType)")
//            let enemyNode = GalaxyBlip(sectorType: galaxyModel.map[i-1].sectorType)
//            currentGrid?.addChildNode(enemyNode)
//        }
//
////        let sectorString = "\(self.ship.targetSectorNumber)"
////        let targetGrid = galacticDisplay.map.rootNode.childNode(withName: sectorString, recursively: true)
////        if let tg = targetGrid {
////            galacticDisplay.oldTargetIndicator.worldPosition = tg.worldPosition
////
////        }
//
//        let currentSectorString = "\(self.ship.currentSectorNumber+1)"
//        devLog("currentSectorString:  \(currentSectorString)")
//        let presentGrid = galacticDisplay.map.rootNode.childNode(withName: currentSectorString, recursively: true)
//

    }

    // MARK: - Game Loop

    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
     }
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if let pause = self.scnView.scene?.isPaused {
        if !gameOver && !pause {
        cleanSceneAndUpdateSectorNodeObjects()
        updateTactical()
        updateStars()
        } else {
            removeMarkedSectorObjects()
            shipHud.deactivateAlert()
            ship.tacticalDisplayEngaged = false
        }
    }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if !gameOver {
            if ship.energyStore <= 0 {
                boomAndLose(atNode: ship, cause: "Prototype defense ship destroyed due to GridWarp core containment failure")
            }
        turnShip()
        ship.updateShipSystems(difficulty: difficultyScalar)
        zylonScanner.eulerAngles = sectorObjectsNode.eulerAngles
        if self.shipCurrrentSectorGrid.sectorType == .enemy {
            zylonScanner.updateScanner(with: self.enemyShipsInSector, sceneView: self.spaceScnView)
        } else {
            zylonScanner.updateScanner(with: self.enemyShipsInSector, sceneView: self.spaceScnView)
        }
        //self.shipHud.updateHUD()

         DispatchQueue.main.async {
            self.shipHud.shields.isHidden = !self.ship.shieldsAreUp
            if self.gameOver {self.shipHud.shields.isHidden = false}
        }

        switch self.viewMode {

        case .aftView:
            DispatchQueue.main.async {
                self.sectorStack.isHidden = true
                self.zylonScanner.isHidden = !self.ship.tacticalDisplayEngaged
                self.tacticalDisplay.isHidden = !self.ship.tacticalDisplayEngaged
                self.speedStack.isHidden = false
                self.joystickControl.isHidden = false
                self.mapScnView.isHidden = true
                self.galacticSlider.isHidden = true
                self.scnView.isHidden = false
                self.galacticStack.isHidden = true
                self.commandStack.isHidden = false
                self.scnView.pointOfView = self.rearCameraNode

                //self.shipHud.aftView()

            }
        case .foreView:
            DispatchQueue.main.async {

                self.sectorStack.isHidden = true
                self.zylonScanner.isHidden = !self.ship.tacticalDisplayEngaged
                self.tacticalDisplay.isHidden = !self.ship.tacticalDisplayEngaged
                self.speedStack.isHidden = false
                self.joystickControl.isHidden = false
                self.mapScnView.isHidden = true
                self.galacticSlider.isHidden = true
                self.scnView.isHidden = false
                self.galacticStack.isHidden = true
                self.commandStack.isHidden = false
                self.spaceScnView.pointOfView = self.forwardCameraNode
                self.shipHud.foreView()
            }
        case .galacticMap:
                DispatchQueue.main.async {
                    self.sectorStack.isHidden = false
                    self.commandStack.isHidden = false
                    self.tacticalDisplay.isHidden = true
                    self.joystickControl.isHidden = true
                    self.mapScnView.isHidden = false
                    if let x  = self.mapScnView.scene?.rootNode {
                        x.isHidden = !self.galacticDisplay.threeDMode
                    }
                    self.classicMap.isHidden = self.galacticDisplay.threeDMode
                    self.galacticSlider.isHidden = false
                    self.scnView.isHidden = true
                    self.galacticStack.isHidden = false
                    self.speedStack.isHidden = true
                    self.mapScnView.allowsCameraControl = false

            }
        }
        } else { // Game over. hide all displays
            DispatchQueue.main.async {
            self.sectorStack.isHidden = true
            self.commandStack.isHidden = true
            self.tacticalDisplay.isHidden = true
            self.joystickControl.isHidden = true
            self.mapScnView.isHidden = true
            self.galacticSlider.isHidden = true
            self.galacticStack.isHidden = true
            self.speedStack.isHidden = true
            self.mapButton.isHidden = true
            }
        }

    }

    // MARK: - Generic iOS Setup

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var shouldAutorotate: Bool {
        return false
    }
}
