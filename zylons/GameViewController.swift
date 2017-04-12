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

    struct Constants {
        static let maxTorpedoes = 5
        static let shotDelay = 1
        static let thrustAmount: Float = 5.0
        }
    
    let numberstrings:[String] = ["zero", "one", "two", "three","four","five","six","seven","eight","nine"]
    

    var scene:SCNScene!
    var scnView:SCNView!
    var cameraNode = SCNNode()
    var rearCameraNode = SCNNode()
    var starfield: SCNParticleSystem!
    var shipHud: HUD!
    var enemyDrone:SCNNode!
    
    
    var engineSound: AVAudioPlayer!
    var shieldSound: AVAudioPlayer!
    var photonSound1: AVAudioPlayer!
    var photonSound2: AVAudioPlayer!
    var photonSound3: AVAudioPlayer!
    var photonSound4: AVAudioPlayer!
    var beepsound: AVAudioPlayer!
    var computerVoice: AVQueuePlayer!
    var environmentSound: AVAudioPlayer!

    
    
    
    var motionManager: CMMotionManager!
    var currentPhoton = 0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    private var timeFiring = 0.0
    private var timeLastFired = 0.0

    
    var myMCController = MCController.sharedInstance

    
    @IBOutlet weak var currentSpeed: UILabel!

    
    
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
    
    @IBAction func gridWarp(_ sender: UIButton) {
        enterSector()
    }
    @IBAction func speedChanged(_ sender: UIStepper)
    {
        computerBeepSound("beep")
        let targetSpeed = sender.value
        setSpeed(Float(targetSpeed))
        
    }
    
    func setSpeed(_ value: Float)
    {
        let displaySpeed = Int(value)
        currentSpeed.text = "\(displaySpeed)"
        starfield.speedFactor = CGFloat(0.4 * value)
        
        if (value == 0)
        {
               SCNTransaction.animationDuration = 0.5
            starfield.speedFactor = CGFloat(0)
            if #available(iOS 10.0, *) {
                engineSound.setVolume(0, fadeDuration: 1.0)
            } else {
                // Fallback on earlier versions
            }
            
        }
        
        if (value == 1)
        {
            SCNTransaction.animationDuration = 1.0
            starfield.speedFactor = CGFloat(1)
            if #available(iOS 10.0, *) {
                engineSound.setVolume(1, fadeDuration: 1.0)
            } else {
                // Fallback on earlier versions
            }
        }
        

    
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
        scene.rootNode.addChildNode(torpedoNode)
        torpedoNode.position = SCNVector3Make(0, -6, 0)
        torpedoNode.physicsBody?.applyForce(SCNVector3Make(0,3,-75), asImpulse: true)
        
        let photonSoundArray = [photonSound1,photonSound2,photonSound3,photonSound4]
        let currentplayer = photonSoundArray[currentPhoton]
            
        currentplayer?.play()
        currentPhoton = currentPhoton+1
        if currentPhoton>(photonSoundArray.count - 1) {currentPhoton = 0}
        
        cleanScene()
        var numberofNodes = 0
        scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            numberofNodes = numberofNodes + 1
        }
        print("number of live nodes:\(numberofNodes)")
           }
        
        else
        {
            computerBeepSound("torpedo_fail")
           
        }
    }
    

    @IBAction func Up(_ sender: UIButton) {
        self.starfield.acceleration.y += Constants.thrustAmount

    }

    @IBAction func Down(_ sender: Any) {
        self.starfield.acceleration.y -= Constants.thrustAmount

    }
    
    
    
    
    
    @IBAction func spawnShip(_ sender: UIButton) {
        
        let modelScene = SCNScene(named: "TIE-fighter.scn", inDirectory: "")
        let enemyDrone = modelScene!.rootNode.childNode(withName: "tieFighter", recursively: true)

        

        
        enemyDrone?.scale = SCNVector3Make(0.25,0.25,0.25)
        print("enemyDrone scale: \(String(describing: enemyDrone?.scale))")
        enemyDrone?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        enemyDrone?.physicsBody?.isAffectedByGravity = false
        enemyDrone?.physicsBody?.categoryBitMask = 0b00000010
        enemyDrone?.physicsBody?.contactTestBitMask = 0b00000010
        enemyDrone?.name = "drone"
        enemyDrone?.position = SCNVector3Make(0, 0, -86)
        enemyDrone?.physicsBody?.applyTorque(SCNVector4Make(1,0.0,1,50), asImpulse: true)
        scene.rootNode.addChildNode(enemyDrone!)
        enemyDrone?.scale = SCNVector3Make(0.25,0.25,0.25)
        enemyDrone?.position = SCNVector3Make(0, 0, -86)
        enemyDrone?.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5)

    }
    
    
    @IBOutlet weak var viewButton: UIButton!
    @IBAction func toggleView(_ sender: UIButton) {
        
        computerBeepSound("beep")
        if sender.currentTitle == "AFT"
        {
            print("Aft Cam")
            sender.setTitle("FORE", for: .normal)
            scnView.pointOfView = rearCameraNode
        }
        
        else
        {
        print("Forward Cam")

            sender.setTitle("AFT", for: .normal)
        scnView.pointOfView = cameraNode

        }
        
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
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        setupMotion()
        setupScene()
        setupCamera()
        
        scnView.showsStatistics = false
        
        scnView.backgroundColor = UIColor.black
        
        self.myMCController.setup()
        self.myMCController.myCommandDelegate = self

    }
    
    

    
    func setupView()
    {
        scnView = self.view as! SCNView
        
        // 1
        scnView.showsStatistics = false
        // 2
        scnView.allowsCameraControl = false
        // 3
        scnView.autoenablesDefaultLighting = true
        
        
        scnView.isPlaying = true
        
        
        
    }
    
    func setupScene()
    {
        scene = SCNScene()
        scnView.scene = scene
        
        
        
        let particlesNode = SCNNode()
        starfield = SCNParticleSystem(named: "starField", inDirectory: "")
        starfield.speedFactor = CGFloat(2)
        particlesNode.name = "starfield"
        particlesNode.addParticleSystem(starfield!)
        scene.rootNode.addChildNode(particlesNode)
        shipHud = HUD(size: self.view.bounds.size)
        scnView.overlaySKScene = shipHud
        scene.physicsWorld.contactDelegate = self
        scnView.delegate = self

        
        var soundURL:URL?
        soundURL = Bundle.main.url(forResource: "ship_hum", withExtension:"mp3")
        try! engineSound = AVAudioPlayer(contentsOf: soundURL!)
        engineSound.numberOfLoops = -1
        engineSound.volume = 1
        engineSound.play()
        
        
        currentPhoton = 0
        soundURL = Bundle.main.url(forResource: "photon_sound", withExtension:"mp3")
        try! photonSound1 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound2 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound3 = AVAudioPlayer(contentsOf: soundURL!)
        try! photonSound4 = AVAudioPlayer(contentsOf: soundURL!)
        
        
        
        
    }
    
    func setupCamera()
        
    {

 
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        print(cameraNode.rotation)
        cameraNode.name = "camera"
        cameraNode.camera?.zFar = 260
        scene.rootNode.addChildNode(cameraNode)
        //scene.rootNode.childNode(withName: "starfield", recursively: true)?.addChildNode(cameraNode)
        
        rearCameraNode.camera=SCNCamera()
        rearCameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        rearCameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi)
        rearCameraNode.name = "rearCamera"
        rearCameraNode.camera?.zFar = 260
        scene.rootNode.addChildNode(rearCameraNode)

        
        
        
      
    }
    
    
    
    func setupMotion()
    {
      motionManager = CMMotionManager()
      motionManager.accelerometerUpdateInterval = 0.3
        
        
      motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
          //  let acceleration = accelerometerData?.acceleration
        
         //   let accelX = Float(4.8 * (acceleration?.y)!)
         //   let accelY = Float(4.8 * (acceleration?.x)!)
        
        }


      motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.checkMotion(gyro: gyroData!.rotationRate)
            if (NSError != nil){
                print("\(String(describing: NSError))")
            }
            
            
        })
      
        
        
    }
    func checkMotion(gyro: CMRotationRate)
    {
        
        
        self.starfield.acceleration = SCNVector3(x: Float(gyro.x * -5), y:Float(gyro.y * -5), z: 0)

        
        
    }
    
    
    func cleanScene()
    {
        scene.rootNode.enumerateChildNodes({thisNode,_ in
            
            if ((thisNode.presentation.position.z < -200) && (thisNode.name == "torpedo"))
            {
                thisNode.removeFromParentNode()
            }
            
            if (thisNode.name == "explosionNode")
            {
                thisNode.removeFromParentNode()
                
            }
        })
        
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
        cleanScene()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

extension GameViewController: CommandDelegate {

 // receive commands from iOS remote controller 
    
    func execute(command: String) {
        print ("executing Command!")
        switch command {
        
        case "Shields":
            toggleShields()
        case "Computer Status":
            enterSector()

        case "Warp 9":
            setSpeed(9)
        case "Warp 3":
            setSpeed(3)

        case "Full Stop":
            setSpeed(0)
            
        case "Fire Photons!":
            fireTorpedo(UIButton())
        default:
            break
        
        }
    }


}

