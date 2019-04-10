//
//  HUD.swift
//  Zylon Defenders
//
//  Created by Jeffery Glasse on 12/30/16.
//  Copyright © 2016 Jeffery Glasse. All rights reserved.
//

//
import UIKit
import SpriteKit
import AVFoundation
import SceneKit

class HUD: SKScene {
    var shields: SKShapeNode!
    var crosshairs: SKSpriteNode!
    var aftcrosshairs: SKSpriteNode!
    var parentScene: ZylonGameViewController?
    public var computerStatus = SKLabelNode()
    public var enemyIndicator = SKLabelNode()
    private let aftHairs = SKSpriteNode(imageNamed: "xenonHUDAFT")
    private let foreHairs = SKSpriteNode(imageNamed: "xenonHUD")

    var timer: Timer?
    var currentComputerStatusColor = UIColor.red

	var tacticalDisplay = [SKSpriteNode]()

    @objc func blinkComputerDisplay() {
        if computerStatus.fontColor == currentComputerStatusColor {computerStatus.fontColor = UIColor.clear} else {computerStatus.fontColor = currentComputerStatusColor}
    }

    public func foreView() {
        print("fore View")
        DispatchQueue.main.async {
        self.crosshairs.isHidden = false
        }
    }

    public func aftView() {
        print("aft View")
        DispatchQueue.main.async {
            self.crosshairs.isHidden = true
        }
    }
    public func mapView() {
        print("aft View")
        DispatchQueue.main.async {
            self.crosshairs.isHidden = true
        }
    }

    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        shields = SKShapeNode(rectOf: size)
        shields.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        shields.alpha = 0.2
        shields.fillColor = SKColor.blue
        shields.strokeColor =  UIColor.clear
        computerStatus.fontName = "Y14.5M 17.0"
        computerStatus.fontSize = 10
        computerStatus.fontColor = UIColor.red
        computerStatus.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-40)

        enemyIndicator.fontName = "Y14.5M 17.0"
        enemyIndicator.fontSize = 10
        enemyIndicator.fontColor = UIColor.red
        computerStatus.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-54)

        updateHUD()

        self.addChild(shields)

        crosshairs = foreHairs
        crosshairs.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(crosshairs)

        self.addChild(computerStatus)
        //self.activateAlert()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

     func updateHUD() {
        if let myScene = self.parentScene {
            let myX = myScene.ship.currentSector.quadrant
            let myY = myScene.ship.currentSector.qx
            let myZ = myScene.ship.currentSector.qy
            computerStatus.text = "CURRENT SECTOR: \(myX).\(myY).\(myZ)"
            if myScene.enemyShipsInSector.count>0 {
                enemyIndicator.color = UIColor.red
                enemyIndicator.text = "ENEMIES IN RANGE: \(myScene.enemyShipsInSector.count)"
                myScene.computerBeepSound("enemyAlert")

            } else {
                enemyIndicator.color = UIColor.green
                enemyIndicator.text = "SECTOR CLEARED"
                myScene.computerBeepSound("sectorCleared")
            }
        }
    }

    func activateAlert() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(self.blinkComputerDisplay), userInfo: nil, repeats: true)
        }
    }

}
