//
//  HUD.swift
//  A spritekit overlay layer for Zylon Defenders
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
    // MARK: - Vars

    var numberOfAlertRepeats = 0
    public var computerStatus = SKLabelNode()
    public var enemyIndicator = SKLabelNode()
    var shields: SKShapeNode!
    var crosshairs: SKSpriteNode!
    var aftcrosshairs: SKSpriteNode!
    var parentScene: ZylonGameViewController?
    let aftHairs = SKSpriteNode(imageNamed: "xenonHUDAFT")
    let foreHairs = SKSpriteNode(imageNamed: "xenonHUD")
    var alertTimer: Timer?
    var currentComputerStatusColor = UIColor.red

	var tacticalDisplay = [SKSpriteNode]()
    // MARK: - Initialization

    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        shields = SKShapeNode(rectOf: size)
        shields.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        shields.alpha = 0.14
        shields.fillColor = SKColor.blue
        shields.strokeColor =  UIColor.clear
        computerStatus.fontName = "Y14.5M 17.0"
        computerStatus.fontSize = 10
        computerStatus.fontColor = UIColor.green
        computerStatus.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-40)

        enemyIndicator.fontName = "Y14.5M 17.0"
        enemyIndicator.fontSize = 10
        enemyIndicator.fontColor = UIColor.green
        enemyIndicator.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-54)

        updateHUD()

        self.addChild(shields)

        crosshairs = foreHairs
        crosshairs.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(crosshairs)
        self.addChild(computerStatus)
        self.addChild(enemyIndicator)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    @objc func blinkComputerDisplay() {
        self.numberOfAlertRepeats += 1
        if self.numberOfAlertRepeats > 8 {self.alertTimer?.invalidate() }
        if computerStatus.fontColor == currentComputerStatusColor {computerStatus.fontColor = UIColor.clear} else {computerStatus.fontColor = currentComputerStatusColor
            self.parentScene?.envSound("alert")
            }
    }

    public func foreView() {
        DispatchQueue.main.async {
            self.crosshairs = self.foreHairs
        }
    }

    public func aftView() {
        DispatchQueue.main.async {
            self.crosshairs = self.aftHairs

        }
    }
    public func mapView() {
        print("map View")
        DispatchQueue.main.async {
            self.crosshairs.isHidden = true
        }
    }

    func shieldHit(location: CGPoint) {
        let shieldSprite = SKSpriteNode(imageNamed: "shieldHit")
        shieldSprite.size.width = shieldSprite.size.width/3
        shieldSprite.size.height = shieldSprite.size.height/3

        shieldSprite.position = location
        self.addChild(shieldSprite)
        shieldSprite.run(SKAction.fadeOut(withDuration: 1.0), completion: {shieldSprite.removeFromParent()})
    }

     func updateHUD() {
        if let myScene = self.parentScene {

            if myScene.ship.isInAlertMode {
                computerStatus.text = "ALERT"

            } else {
            let myX = myScene.ship.currentSector.quadrant
            let myY = myScene.ship.currentSector.qx
            let myZ = myScene.ship.currentSector.qy
            computerStatus.text = "CURRENT SECTOR: \(myX).\(myY).\(myZ)"
            }

            if myScene.enemyShipsInSector.count > 0 {
                enemyIndicator.color = UIColor.red
                enemyIndicator.text = "ENEMIES IN RANGE: \(myScene.enemyShipsInSector.count)"
                myScene.computerBeepSound("enemyAlert")

            } else {
                enemyIndicator.color = UIColor.green
                enemyIndicator.text = "SECTOR CLEARED"
            }
        }
    }

    func activateAlert() {
        DispatchQueue.main.async {
            self.computerStatus.text = "ALERT"
            self.alertTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(self.blinkComputerDisplay), userInfo: nil, repeats: true)
        }
    }

}
