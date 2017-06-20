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

class GameViewController: UIViewController,SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    // MARK: -
    // MARK: Constants
    struct Constants {
        static let maxTorpedoes = 5
        static let shotDelay = 1
        static let thrustAmount: Float = 15.0
        }
    
        let numberstrings:[String] = ["zero", "one", "two", "three","four","five","six","seven","eight","nine"]
    
    // add multipeer Connectivity
    var myMCController = MCController.sharedInstance

    
    // MARK: -
    // MARK: Vars
    // drone model
    var droneModel: SCNNode!
    

    var scene:SCNScene!
    var scnView:SCNView!
    var cameraNode = SCNNode()
    var rearCameraNode = SCNNode()
	var particlesNode = SCNNode()

	var starSprites = [SCNNode]()
	let sectorObjectsNode = SCNNode()
	
	
    var enemyDrone:SCNNode!
	
	var ship = Ship()
	var shipHud: HUD!

	
    
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
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    private var timeFiring = 0.0
    private var timeLastFired = 0.0
    
    


    // MARK:  - IBOutlets and Actions
    

	@IBOutlet weak var tacticalDisplay: UIView!
	
	@IBAction func showTactical(_ sender: Any) {
			tacticalDisplay.isHidden = !tacticalDisplay.isHidden
		
	}
	
    @IBOutlet weak var joystickSettings: UILabel!
    
	@IBOutlet weak var currentSpeed: UILabel!
	@IBOutlet weak var viewButton: UIButton!
    
    
    @IBAction func toggleView(_ sender: UIButton) {
		SCNTransaction.animationDuration = 0.4

		if scnView.pointOfView == cameraNode
        {
			sender.setTitle("AFT", for: .normal)
            aftView()
        }
            
        else
        {
			sender.setTitle("FORE", for: .normal)
            foreView()
        }
        computerBeepSound("beep")
		SCNTransaction.animationDuration = 0.0


        
    }
    @IBAction func fireTorpedo(_ sender: UIButton)
    {
        if (numberofShotsOnscreen() < Constants.maxTorpedoes)
        {
            let torpedoNode = SCNNode(geometry: SCNSphere(radius: 0.25))
            torpedoNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            torpedoNode.physicsBody?.isAffectedByGravity = false
            torpedoNode.name = "torpedo"
            torpedoNode.physicsBody?.categoryBitMask = 0b00000010
            torpedoNode.physicsBody?.contactTestBitMask = 0b00000010
            
            let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
            torpedoNode.addParticleSystem(torpedoSparkle!)
			let photonSoundArray = [photonSound1,photonSound2,photonSound3,photonSound4]
			let currentplayer = photonSoundArray[currentPhoton]
			
			scene.rootNode.addChildNode(torpedoNode)
			let driftAmount: Float = 2
			let offset: Float = 4
			let forceAmount: Float = -95
			if ship.currentTorpedoBay == 1
			{
			ship.currentTorpedoBay = 2
            torpedoNode.position = SCNVector3Make(offset, -2, 0)
            torpedoNode.physicsBody?.applyForce(SCNVector3Make(-driftAmount,1.7,forceAmount), asImpulse: true)
            }
			
			else
			{
				ship.currentTorpedoBay = 1

				torpedoNode.position = SCNVector3Make(-offset, -2, 0)
				torpedoNode.physicsBody?.applyForce(SCNVector3Make(driftAmount,1.7,forceAmount), asImpulse: true)
				
			}
			
			
			
            currentplayer?.play()
            currentPhoton = currentPhoton+1
            if currentPhoton>(photonSoundArray.count - 1) {currentPhoton = 0}
            
          countNodes()
        }
            
        else
        {
            computerBeepSound("torpedo_fail")
            
        }
    }
    
	let rotateAmount: Float = 0.5
	
    @IBAction func Up(_ sender: UIButton) {
//        particlesNode.eulerAngles.x += rotateAmount
		
    }
    
    @IBAction func Down(_ sender: Any) {
//        self.particlesNode.eulerAngles.x -= rotateAmount
		
    }
    
    @IBAction func Right(_ sender: UIButton) {
//        self.particlesNode.eulerAngles.y -= rotateAmount

    }
    
    @IBAction func Left(_ sender: UIButton) {
//        self.particlesNode.eulerAngles.y += rotateAmount

    }
    
    
    
    
    
    @IBAction func spawnShip(_ sender: UIButton) {
        
        
        let pyramid = SCNPyramid(width: 9.0, height: 9.0, length: 9.0)
        enemyDrone = SCNNode()
        enemyDrone.geometry  = pyramid
        enemyDrone.geometry?.firstMaterial = SCNMaterial()
        enemyDrone.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        enemyDrone?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        enemyDrone?.physicsBody?.isAffectedByGravity = false
        enemyDrone?.physicsBody?.friction = 0
        enemyDrone?.physicsBody?.categoryBitMask = 0b00000010
        enemyDrone?.physicsBody?.contactTestBitMask = 0b00000010
        enemyDrone?.name = "drone"
        enemyDrone?.physicsBody?.applyTorque(SCNVector4Make(1,0.0,1,10), asImpulse: true)
        enemyDrone?.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        sectorObjectsNode.addChildNode(enemyDrone!)
        enemyDrone?.position = SCNVector3Make(0, 0, -70)
        enemyDrone?.scale = SCNVector3Make(1,1,1)
        
    }
    
	
	
	@IBOutlet weak var stepperSpeed: UIStepper!
	@IBAction func gridWarp(_ sender: UIButton) {
        performWarp()
		let deadlineTime = DispatchTime.now() + .seconds(6)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime)
		{
			self.enterSector()
			self.setSpeed(1)
		}
    }
	
	
    @IBAction func speedChanged(_ sender: UIStepper)
    {
        computerBeepSound("beep")
        let targetSpeed = sender.value
		
        setSpeed(Int(targetSpeed))
        
    }
    
    
 
     // MARK:  - Sound Functions
    
    func environmentSound(_ soundString: String)
    {
        let soundURL = Bundle.main.url(forResource: soundString, withExtension:"m4a")
        try! environmentSound = AVAudioPlayer(contentsOf: soundURL!)
        environmentSound.volume = 0.5
        environmentSound.play()
    }
    
    func computerBeepSound(_ soundString: String)
    {
       let soundURL = Bundle.main.url(forResource: soundString, withExtension:"mp3")
       try! beepsound = AVAudioPlayer(contentsOf: soundURL!)
        beepsound.volume = 0.5
        beepsound.play()

    }
    
   
    func setSpeed(_ newSpeed: Int)
    {
		let speedChange = abs(newSpeed - ship.currentSpeed)
        SCNTransaction.animationDuration = 2.0 * Double(speedChange)
		SCNTransaction.begin()
		ship.currentSpeed = newSpeed
		currentSpeed.text = "\(ship.currentSpeed)"
        SCNTransaction.commit()
        if (newSpeed == 0)
        {
			engineSound.setVolume(0, fadeDuration: 1.0)
        }
        if (newSpeed == 1)
        {
			engineSound.setVolume(1, fadeDuration: 1.0)
		}
		
    }
    
    
  
    
    func aftView() {
        scnView.pointOfView = rearCameraNode
		
    }
    
    func foreView() {
        scnView.pointOfView = cameraNode

    }
    
    @IBAction func Shields(_ sender: UIButton)
    {
        shipHud.toggleShields()
        computerBeepSound("shields")
        
    }
    
	func toggleShields()
    {
		
        shipHud.toggleShields()
        computerBeepSound("shields")
    }
    
    
    //MARK: -  SETUP
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        setupScene()
		createStars()
        setupShip()
        myMCController.setup()
        myMCController.myCommandDelegate = self
        shipHud.myscene = self

    }
    
    

    
    func setupView()
    {
        scnView = self.view as! SCNView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        scnView.backgroundColor = UIColor.black
    }
	
    func setupScene()
    {
        scene = SCNScene()
        scnView.scene = scene
        
        // setup HUD
        shipHud = HUD(size: self.view.bounds.size)
        scnView.overlaySKScene = shipHud
        scene.physicsWorld.contactDelegate = self
        scnView.delegate = self

        
		playEngineSound(volume:1)
		
		setupPhotonSounds()
		
		
    }
	
	func playEngineSound(volume: Float){
		var soundURL:URL?
		soundURL = Bundle.main.url(forResource: "ship_hum", withExtension:"mp3")
		try! engineSound = AVAudioPlayer(contentsOf: soundURL!)
		engineSound.numberOfLoops = -1
		engineSound.volume = volume
		engineSound.play()
	}
	
	func setupPhotonSounds()
	{
		var soundURL:URL?
		currentPhoton = 0
		soundURL = Bundle.main.url(forResource: "photon_sound", withExtension:"mp3")
		try! photonSound1 = AVAudioPlayer(contentsOf: soundURL!)
		try! photonSound2 = AVAudioPlayer(contentsOf: soundURL!)
		try! photonSound3 = AVAudioPlayer(contentsOf: soundURL!)
		try! photonSound4 = AVAudioPlayer(contentsOf: soundURL!)
}
	
	
	
	func randRange (lower: Float , upper: Float) -> Float {
		return lower + Float(arc4random_uniform(UInt32(upper - lower + 1)))
	}
	
	func updateStars(){
		for star in self.starSprites{
			// TODO: refactor to calculate ship vector on all three axes
		star.position.z += Float(ship.currentSpeed)
				if star.position.z > 400
				{
					star.position.z = randRange(lower: -400, upper: -200)
					star.position.x = randRange(lower: -100, upper: 100)
					star.position.y = randRange(lower: -100, upper: 100)
				}
			}

		}
	
	
	
	func createStars()
	{
		sectorObjectsNode.name = "sectorObjectsNode"
		
		scene.rootNode.addChildNode(sectorObjectsNode)
		for _ in 1...300{
			let x = randRange(lower: -50, upper: 50)
			let y = randRange(lower: -50, upper: 50)
			let z = randRange(lower: -400, upper: 400)
			let sphere = SCNSphere(radius: 0.25)
			let starSprite = SCNNode()
			starSprite.geometry  = sphere
			starSprite.position.x = x
			starSprite.position.y = y
			starSprite.position.z = -z
			starSprite.geometry?.firstMaterial = SCNMaterial()
			starSprite.geometry?.firstMaterial?.diffuse.contents = UIColor.white
			starSprite.name = "star"
			starSprites.append(starSprite)
			sectorObjectsNode.addChildNode(starSprite)
			sectorObjectsNode.renderingOrder = -1

		}
	
	
	
	}
	
    func setupShip()
    {
		scene.rootNode.addChildNode(self.ship)
		self.ship.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.camera = SCNCamera()
		cameraNode.camera?.focalSize = 700
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        print(cameraNode.rotation)
        cameraNode.name = "camera"
        cameraNode.camera?.zFar = 500
		//cameraNode.camera?.fieldOfView = 120
		
		
		self.ship.addChildNode(cameraNode)
        
        rearCameraNode.camera=SCNCamera()
        rearCameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        rearCameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi)
        rearCameraNode.name = "rearCamera"
        rearCameraNode.camera?.zFar = 400
		
        self.ship.addChildNode(rearCameraNode)
		ship.currentSpeed = 5
		
       // cameraNode.addChildNode(particlesNode)

        
      
    }
    
    
	
    
    //MARK: -  Game Event functions
    func performWarp() {
		var audioItems: [AVPlayerItem] = []
		let soundURL = Bundle.main.url(forResource: "warpStart", withExtension:"aif")
		let engineStart = AVPlayerItem(url: soundURL!)
		let soundURL2 = Bundle.main.url(forResource: "warpEnd", withExtension:"aif")
		let engineEnd = AVPlayerItem(url: soundURL2!)

		audioItems.append(engineStart)
		audioItems.append(engineEnd)
		warpEngineSound = AVQueuePlayer(items: audioItems)
		warpEngineSound.volume = 0.9
		warpEngineSound.play()

		
        let warpGridEntryShape = SCNTube(innerRadius: 2, outerRadius: 2, height: 220)
		
        
        let  warpGrid = SCNNode()
        warpGrid.geometry  = warpGridEntryShape
        
        
        warpGrid.geometry?.firstMaterial = SCNMaterial()
        let innerTube = SCNMaterial()
        innerTube.diffuse.contents =  UIColor.black
        innerTube.emission.contents =  UIImage(named:"smallestGrid.png")
        
        warpGrid.opacity = 0.25
        let outerTube = SCNMaterial()
        outerTube.emission.contents =  UIImage(named:"smallestGrid.png")
        outerTube.diffuse.contents = UIColor.black
        let endOne = SCNMaterial()
        endOne.diffuse.contents =  UIColor.blue
        let endTwo = SCNMaterial()
        endTwo.diffuse.contents =  UIColor.purple
        
		
        warpGrid.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        warpGrid.physicsBody?.isAffectedByGravity = false
        warpGrid.physicsBody?.applyForce(SCNVector3Make(0,0,35), asImpulse: true)
        warpGrid.physicsBody?.friction = 0
        warpGrid.physicsBody?.categoryBitMask = 0b00000010
        warpGrid.physicsBody?.contactTestBitMask = 0b00000000
        warpGrid.name = "warpGrid"
		
       // warpGrid.geometry?.firstMaterial?.isDoubleSided = true
        warpGrid.geometry?.materials = [outerTube,innerTube,endOne,endTwo]
        // warpGrid.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)
        warpGrid.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 2))
        warpGrid.position = SCNVector3Make(0, 0, -300)
		warpGrid.scale = SCNVector3Make(1,1,1)
		warpGrid.opacity = 0
		scene.rootNode.addChildNode(warpGrid)
		
        // WARP!
        let pov = scnView.pointOfView!
		
        let adjustCamera = SCNAction.run { _ in
			
			self.setSpeed(20)
			self.stepperSpeed.value = 20
			warpGrid.opacity = 1
            warpGrid.physicsBody?.applyForce(SCNVector3Make(0,0,55), asImpulse: true)
            self.cameraNode.camera?.xFov = 70
			pov.camera?.motionBlurIntensity = 0.0
        }
		
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 4.0
        pov.runAction(adjustCamera)
        
        SCNTransaction.commit()

        
    }
    func enterSector()
    {
        var audioItems: [AVPlayerItem] = []
        let soundURL = Bundle.main.url(forResource: "entering_sector", withExtension:"m4a")
        let sector = AVPlayerItem(url: soundURL!)
        audioItems.append(sector)
        
        
        print("Entering sector:", terminator:"")
        for i in 1...4
        {
            let randomIndex = Int(arc4random_uniform(UInt32(self.numberstrings.count)))
            let numString = numberstrings[randomIndex]
            if i < 4
            {print(numString + "-", terminator:"")}
            else
            {print(numString)}
            let soundURL = Bundle.main.url(forResource: numString, withExtension:"m4a")
            let item = AVPlayerItem(url: soundURL!)
            audioItems.append(item)
            
        }
        computerVoice = AVQueuePlayer(items: audioItems)
        computerVoice.volume = 1
        computerVoice.play()
    }
	
    //MARK: -  Utility functions

    func notYetImplemented(_ command: String) {
        print("\(command) not yet implemented")
    }

    func checkMotion(gyro: CMRotationRate)
    {
        self.cameraNode.rotation.x = self.cameraNode.rotation.x + Float(gyro.x)
        self.cameraNode.rotation.y = self.cameraNode.rotation.y + Float(gyro.y)
        if let tempDrone = self.enemyDrone {
        tempDrone.position.x = self.enemyDrone.position.x - 0.08 * Float(gyro.x)
        tempDrone.position.y = self.enemyDrone.position.y - 0.08 * Float(gyro.y)

        }
    }
    
    func cleanScene()
    {
        scene.rootNode.enumerateChildNodes({thisNode,_ in
			
			
			// remove torpedoes - refactor to be time since torpedo launched

            if ((thisNode.presentation.position.z < -300) && (thisNode.name == "torpedo"))
            {
                thisNode.removeFromParentNode()
            }
			
			
			// remove explosions - refactor to provide timer for each explosion

            if (thisNode.name == "explosionNode")
            {
				explosionDuration += 1
				if explosionDuration > 10
				{
					thisNode.removeFromParentNode()
					explosionDuration = 0
				}
            }
			
			// remove warpgrid - refactor to be time since warpgrid
            if ((thisNode.presentation.position.z > 110) && (thisNode.name == "warpGrid"))
            {
				SCNTransaction.animationDuration = 1
				SCNTransaction.begin()
				thisNode.opacity = 0
				SCNTransaction.commit()
            }
       })
        
}

    func countNodes(){
        var numberofNodes = 0
        
        scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            numberofNodes = numberofNodes + 1
        }
        print("number of live nodes:\(numberofNodes)")
        
        
    }
    
    
    func numberofShotsOnscreen() -> Int
    {
    var numberOfShots = 0

        scene.rootNode.enumerateChildNodes({ (child, stop) in
            if (child.name == "torpedo")
                {  numberOfShots = numberOfShots+1}
            })

    return numberOfShots
    
    
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact)
    {
            let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil)
            let explosionNode = SCNNode()
            explosionNode.name = "explosionNode"
			explosionNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
			explosionNode.physicsBody?.applyForce(SCNVector3Make(0,0,75), asImpulse: true)
            explosionNode.addParticleSystem(particleSystem!)
         if (contact.nodeA.name != "torpedo")
            {
                explosionNode.position = contact.nodeA.position
    
            }
        else
            {
                explosionNode.position = contact.nodeB.position
            }
            print("contact.nodeA.name: \(String(describing: contact.nodeA.name))")
            print("contact.nodeA.position: \(contact.nodeA.position)")
            print("contact.nodeB.name: \(String(describing: contact.nodeB.name))")
            print("contact.nodeB.position: \(contact.nodeB.position)")

            scene.rootNode.addChildNode(explosionNode)
            environmentSound("explosion")
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		// check for expired items and remove them
		updateStars()
		cleanScene()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func distanceBetweenPoints(first: CGPoint,  second: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(second.x - first.x), Float(second.y - first.y)))
    }

}

extension GameViewController: CommandDelegate {

 // receive commands from iOS remote controller 
    

    func execute(command: String) {
        print ("executing Command!")
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

