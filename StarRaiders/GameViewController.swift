//
//  GameViewController.swift
//  StarRaiders
//
//  Created by Jeffery Glasse on 11/6/16.
//  Copyright © 2016 Jeffery Glasse. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    var scene:SCNScene!
    var scnView:SCNView!
    var cameraNode: SCNNode!
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
    

    var currentPhoton = 0
    
    

    
    
    let maxShots = 3
    let shotDelay = 1
    private var timeFiring = 0.0
    private var timeLastFired = 0.0
    
    
    @IBAction func spawnShip(_ sender: UIButton) {
        let enemyDrone = SCNNode(geometry: SCNSphere(radius: 3.7))
        enemyDrone.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        enemyDrone.physicsBody?.isAffectedByGravity = false
        enemyDrone.position = SCNVector3Make(0, 0, -86)
        enemyDrone.name = "drone"
        scene.rootNode.addChildNode(enemyDrone)


        
        
    }
    
    
    @IBOutlet weak var currentSpeed: UILabel!
    
    @IBAction func Shields(_ sender: UIButton) {
        shipHud.toggleShields()
        var soundURL:URL?
        soundURL = Bundle.main.url(forResource: "shields", withExtension:"mp3")
        try! shieldSound = AVAudioPlayer(contentsOf: soundURL!)
        shieldSound.volume = 1
        shieldSound.play()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        

    
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
      //  let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
      //  scnView.addGestureRecognizer(tapGesture)
    }
    
   
    
    
        
    @IBAction func speedChanged(_ sender: UIStepper)
    {
        
        let soundURL = Bundle.main.url(forResource: "beep", withExtension:"mp3")
        try! beepsound = AVAudioPlayer(contentsOf: soundURL!)
        beepsound.volume = 0.5
        beepsound.play()
        
        let displaySpeed = Int(sender.value)
        currentSpeed.text = "\(displaySpeed)"
        starfield.speedFactor = CGFloat(0.4 * sender.value)
        if (sender.value == 0)
        {
        SCNTransaction.animationDuration = 1.0
        starfield.speedFactor = CGFloat(0)
            if #available(iOS 10.0, *) {
                engineSound.setVolume(0, fadeDuration: 1.0)
            } else {
                // Fallback on earlier versions
            }

        }
        
        if (sender.value == 1)
        {
            SCNTransaction.animationDuration = 1.0
            starfield.speedFactor = CGFloat(1)
            if #available(iOS 10.0, *) {
                engineSound.setVolume(1, fadeDuration: 1.0)
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        //update engine sound
    }
    
    @IBAction func fireTorpedo(_ sender: UIButton)
    {
        
        
 //       if (numberofShotsOnscreen() < 3)
   //     {
        let torpedoNode = SCNNode(geometry: SCNSphere(radius: 0.25))
        torpedoNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        torpedoNode.physicsBody?.isAffectedByGravity = false    
        torpedoNode.name = "torpedo"

            
        let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
        torpedoNode.addParticleSystem(torpedoSparkle!)
        scene.rootNode.addChildNode(torpedoNode)
        torpedoNode.position = SCNVector3Make(0, -6, 0)
        torpedoNode.physicsBody?.velocity = SCNVector3Make(0,3,-75)
        let photonSoundArray = [photonSound1,photonSound2,photonSound3,photonSound4]
        let currentplayer = photonSoundArray[currentPhoton]
        currentplayer?.play()
        currentPhoton = currentPhoton+1
        if currentPhoton>(photonSoundArray.count - 1) {currentPhoton = 0}
        
        cleanScene()

     //   }
    }
    
    func cleanScene() {
        // 1
        scene.rootNode.enumerateChildNodes({ (child, stop) in
            if (child.position.z < -1000)
            {  child.removeFromParentNode() }
        })
        
    }
    


    
    
    func numberofShotsOnscreen() -> Int
    {
    var numberOfShots = 0
        print ("number of shots: \(numberOfShots)")

        scene.rootNode.enumerateChildNodes({ (child, stop) in
            if (child.name == "torpedo")
                {  numberOfShots = numberOfShots+1}
            })
        print ("number of shots: \(numberOfShots)")

    return numberOfShots
    
    
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
        
        particlesNode.addParticleSystem(starfield!)
        scene.rootNode.addChildNode(particlesNode)
        shipHud = HUD(size: self.view.bounds.size)
        scnView.overlaySKScene = shipHud
        
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
        // 1
        cameraNode = SCNNode()
        // 2
        cameraNode.camera = SCNCamera()
        // 3
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        // 4
        cameraNode.camera?.zFar = 160
        scene.rootNode.addChildNode(cameraNode)
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

