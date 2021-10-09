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

enum Difficulty: String, Codable {
    case Novice = "Cadet"
    case Pilot = "Pilot"
    case Warrior = "Warrior"
    case Commander = "Commander"
    case Lord = "Zylon Lord"
}

struct GameSettings: Codable {
    var prologueEnabled: Bool
    var difficulty: Difficulty
}

class MainMenuViewController: UIViewController, AVAudioPlayerDelegate {

    let musicURL = Bundle.main.url(forResource: "dreadnaught", withExtension: "m4a")
    var musicAudioPlayer: AVAudioPlayer?
    var currentCredit = 0
    let credits = ["based on STAR RAIDERS by Doug Neubauer", "Music by Neon Insect", "Special thanks to Lorenz Wiest", "Programmed and designed by Jeff Glasse", "With many thanks to Aimee for her infinite patience", "Copyright 2019 Nine Industries. All Rights Reserved."]
    var creditTimer: Timer?
    var beepsound: AVAudioPlayer!


    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // MARK: - IBOutlets
    @IBOutlet weak var prologueToggleSwitch: UIButton!
    @IBOutlet weak var mapScnView: SCNView!
    @IBOutlet weak var creditsView: TelemetryPlayer!

    let galaxyScene = SCNScene(named: "galacticmap.scn")!
    var settings = getSettings()

    // MARK: - IBActions

    @IBAction func setDifficulty(_ sender: Any) {
        computerBeepSound("beep")
        creditTimer?.invalidate()
        switch settings.difficulty {
        case .Novice:
                settings.difficulty = .Pilot
        case .Pilot:
                settings.difficulty = .Commander
        case .Commander:
            settings.difficulty = .Warrior
        case .Warrior:
            settings.difficulty = .Lord
        case .Lord:
            settings.difficulty = .Novice
        }
        creditsView.text = "Difficulty: \(settings.difficulty.rawValue)"
        creditsView.quickFadeInandOut()
        save(settings: settings)
        print("saved settings: \(settings)")

    }
    @IBAction func togglePrologue(_ sender: UIButton) {
        computerBeepSound("beep")
        switch settings.prologueEnabled {
        case true:
            prologueToggleSwitch.setTitle("PROLOGUE OFF", for: .normal)
            settings.prologueEnabled = false
        case false:
            prologueToggleSwitch.setTitle("PROLOGUE ON", for: .normal)
            settings.prologueEnabled = true
        }

        save(settings: settings)

    }

    @IBAction func startGame(_ sender: Any) {
        computerBeepSound("beep")
        self.musicAudioPlayer?.setVolume(0, fadeDuration: 1.5)
        self.musicAudioPlayer?.stop()
        var vc: UIViewController
        let sb = UIStoryboard(name: "Main", bundle: nil)

        if settings.prologueEnabled {
            vc = sb.instantiateViewController(withIdentifier: "prologue")
        } else {
            vc = sb.instantiateViewController(withIdentifier: "gameView")

        }
        vc.modalPresentationStyle = .fullScreen
        UIView.animate(withDuration: 1.0, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            self.present(vc, animated: false, completion: nil)
        })

    }

    @IBAction func displayTutorial(_ sender: Any) {
        creditTimer?.invalidate()
        creditsView.alpha = 0.0
        creditsView.text = "Not yet implemented"
        creditsView.quickFadeInandOut()
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

    func displayCredits() {
        self.creditsView.alpha = 0
        self.creditsView.text = credits[0] // prime the pump
        creditTimer = Timer.scheduledTimer(timeInterval: 6.5, target: self, selector: #selector(displayCredit), userInfo: nil, repeats: true)

    }

    @objc func displayCredit() {
        if currentCredit<credits.count {
        self.creditsView.text = credits[currentCredit]
        self.creditsView.fadeInandOut()
        currentCredit+=1
        } else {
            creditTimer?.invalidate()
        }
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

        let rotationNode = galaxyScene.rootNode.childNode(withName: "rotateNode", recursively: true)!
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "gCam"
        galaxyScene.rootNode.addChildNode(cameraNode)

        //point the camera at the galaxy map
        let camConstraint = SCNLookAtConstraint(target: galaxyScene.rootNode)
        camConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [camConstraint]

        // place the camera
        cameraNode.position = SCNVector3(x: -0.5, y: -17, z: 4.2)
        //cameraNode.rotation = SCNVector4
        cameraNode.camera?.focalLength = 28.0

        let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 56)
        let forever = SCNAction.repeatForever(action)
        rotationNode.runAction(forever)
        mapScnView.prepare([galaxyScene], completionHandler: nil)
        self.musicAudioPlayer?.play()
        let transition = SKTransition.fade(withDuration: 0.0)

        self.mapScnView.present(galaxyScene, with: transition, incomingPointOfView: galaxyScene.rootNode.childNode(withName: "gCam", recursively: true), completionHandler: {
            self.mapScnView.allowsCameraControl = false
        })
        self.view.alpha = 0
        self.creditsView.text = ""

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 2.5, animations: {
            self.view.alpha = 1.0
        })
        self.displayCredits()

    }

}

extension UIView {

    func quickFadeInandOut() {
        UIView.animate(withDuration: 0.50, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: andOut(success:))
    }

    func quickOut(success: Bool = true) {
        UIView.animate(withDuration: 0.75, delay: 2.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)

    }

    func fadeInandOut() {
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: andOut(success:))
    }

    func andOut(success: Bool = true) {
        UIView.animate(withDuration: 1.0, delay: 3.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)

    }

    func fadeIn() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }

    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }

}
