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

struct GameSettings: Codable {
    var prologueEnabled: Bool
}


class mainMenuViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var prologueToggleSwitch: UIButton!
    @IBOutlet weak var mapScnView: SCNView!
    let galaxyScene = SCNScene(named: "galacticmap.scn")!
    var settings = getSettings()
    
    // MARK: - IBActions

    @IBAction func togglePrologue(_ sender: UIButton) {
        switch self.settings.prologueEnabled {
        case true:
            prologueToggleSwitch.setTitle("PROLOGUE OFF", for: .normal)
            self.settings.prologueEnabled = false
        default: // handles false and nil
            prologueToggleSwitch.setTitle("PROLOGUE ON", for: .normal)
            self.settings.prologueEnabled = true
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
    override func viewDidLoad() {
        switch self.settings.prologueEnabled {
        case true:
            prologueToggleSwitch.setTitle("PROLOGUE OFF", for: .normal)
        case false: // handles false and nil
            prologueToggleSwitch.setTitle("PROLOGUE ON", for: .normal)
        }

//        let settingsURL: URL = ... // location of plist file
//        var settings: MySettings?
//        do {
//            let data = try Data(contentsOf: settingsURL)
//            let decoder = PropertyListDecoder()
//            settings = try decoder.decode(MySettings.self, from: data)
//        } catch {
//            // Handle error
//            print(error)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.settings = getSettings()
        super.viewWillAppear(animated)
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
    }
    
}
