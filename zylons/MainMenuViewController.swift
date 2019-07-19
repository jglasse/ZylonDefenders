//
//  MainMenuVC.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 7/6/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation

struct GameSettings: Codable {
    var prologueEnabled: Bool
}


class mainMenuViewController: UIViewController, AVAudioPlayerDelegate {
    
    let musicURL = Bundle.main.url(forResource: "dreadnaught", withExtension: "m4a")
    var musicAudioPlayer: AVAudioPlayer?


    // MARK: - IBOutlets
    @IBOutlet weak var prologueToggleSwitch: UIButton!
    @IBOutlet weak var mapScnView: SCNView!
    let galaxyScene = SCNScene(named: "galacticmap.scn")!
    var settings = getSettings()
    
    // MARK: - IBActions

    @IBAction func togglePrologue(_ sender: UIButton) {
        print("togglePrologue entered")
        print("settings:\(settings)")

        switch settings.prologueEnabled {
        case true:
            print("togglePrologue found TRUE; setting to false")
            prologueToggleSwitch.setTitle("PROLOGUE OFF", for: .normal)
            settings.prologueEnabled = false
        case false:
            print("togglePrologue found FALSE; setting to TRUE")
            prologueToggleSwitch.setTitle("PROLOGUE ON", for: .normal)
            settings.prologueEnabled = true
        }
        
        save(settings: settings)

        
    }
    
    @IBAction func startGame(_ sender: Any) {
        var vc: UIViewController
        let sb = UIStoryboard(name: "Main", bundle: nil)

        if settings.prologueEnabled {
            vc = sb.instantiateViewController(withIdentifier: "prologue")
        }
        else {
            vc = sb.instantiateViewController(withIdentifier: "gameView")

        }
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
        // MARK: - View Cycle Methods
   
    func setupMusicAudioPlayer() {
        do {
            
            self.musicAudioPlayer = try AVAudioPlayer(contentsOf: musicURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.musicAudioPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.musicAudioPlayer?.prepareToPlay()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMusicAudioPlayer()
        switch self.settings.prologueEnabled {
        case true:
            prologueToggleSwitch.setTitle("PROLOGUE ON", for: .normal)
        case false: // handles false and nil
            prologueToggleSwitch.setTitle("PROLOGUE OFF", for: .normal)
        }
        print("viewDidLoad settings:\(settings)")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidAppear")
        super.viewDidAppear(animated)
        
        
        let rotationNode =   galaxyScene.rootNode.childNode(withName: "rotateNode", recursively: true)!
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "gCam"
        galaxyScene.rootNode.addChildNode(cameraNode)
        
        //point the camera at the galaxy map
        let camConstraint = SCNLookAtConstraint(target: galaxyScene.rootNode)
        camConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [camConstraint]
        
        // place the camera
        cameraNode.position = SCNVector3(x: -0.5, y: -17, z: 7.2)
        
        
        
        let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 26)
        let forever = SCNAction.repeatForever(action)
        rotationNode.runAction(forever)
        
        let transition = SKTransition.fade(withDuration: 1.0)
        
        self.mapScnView.present(galaxyScene, with: transition, incomingPointOfView: galaxyScene.rootNode.childNode(withName: "gCam", recursively: true), completionHandler: {
            self.mapScnView.allowsCameraControl = true
            print("viewdidAppear ENDS")

        })
        self.musicAudioPlayer?.play()
    }
    
}
