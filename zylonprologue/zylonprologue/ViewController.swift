//
//  ViewController.swift
//  zylonprologue
//
//  Created by Jeffrey Glasse on 11/10/17.
//  Copyright © 2017 GlasseHouseGames. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

class MyViewController: UIViewController, AVAudioPlayerDelegate {
    let writeInterval = 0.040

    var messageArray = [(message: String, delay: Float)]()
    let soundURL = Bundle.main.url(forResource: "wopr", withExtension: "aiff")

    var telemetryPlayer: AVAudioPlayer?

    var currentMessageIndex = 0
    var currentLetterIndex = 0

    var currentLetter = ""
    var existingTelemetry = ""
    var currentMessage = ""

    let message1 = """
They came without warning -  spreading relentlessly across
peaceful federation systems like an unstoppable virus.

The STAR RAIDERS.
"""

    let message2 = """
With warp technology, they quickly established starbases
deep within zylon space, conducting brutal raids which
easily overwhelmed our defenses. In just three centons,
a single raider defeated almost our entire defense force.
"""

    let message3 = """
But a few brave scientists managed to develop an experimental
starcruiser that could defeat the star raiders - and
finally drive them back to their distant homesystem, Sol.

You will pilot that starship.
"""
    let message4 = """

DEFEND THE EMPIRE. DRIVE BACK THE HUMONS. SAVE THE ZYLON RACE.

[END TRANSMISSION]
"""

    @IBOutlet weak var starFieldView: UIImageView!
    @IBOutlet weak var transmissionView: UILabel!

    override func viewDidLoad() {

        super.viewDidLoad()
        // setup Background Image
        let spaceBackground = SKSpriteNode(imageNamed: "Starfield 2048x1024B")
        spaceBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let gameView =  SKView(frame: self.view.frame)
        self.view = gameView
        let gameScene = SKScene(size: gameView.bounds.size)
        spaceBackground.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        spaceBackground.size = gameScene.size

        gameScene.addChild(spaceBackground)

        messageArray = [(message1, 1), (message2, 1), (message3, 1), (message4, 0)]

        let messageLabel = SKLabelNode()
        messageLabel.text = message1

        messageLabel.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        messageLabel.fontSize = 10
        gameScene.addChild(messageLabel)
        gameView.presentScene(gameScene)

       // receiveNewTelemetry(message: message1)
//        do {
//        telemetryPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
//        telemetryPlayer?.delegate = self
//
//        } catch let error {
//            print(error.localizedDescription)
//        }

    }

    func receiveNewTelemetry(message: String) {
        self.currentLetter = ""
        self.existingTelemetry = ""
        self.currentLetterIndex = 0
        self.currentMessage = self.messageArray[currentMessageIndex].message
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        telemetryPlayer?.play()
        let index = self.currentMessage.index(self.currentMessage.startIndex, offsetBy: self.currentLetterIndex)
        self.currentLetter = String(self.currentMessage[index])
        self.existingTelemetry.append(currentLetter)
        self.transmissionView.text = existingTelemetry
        self.transmissionView.setNeedsDisplay()
        if self.currentLetterIndex < self.currentMessage.count-1 {
            self.currentLetterIndex += 1
        } else {
            self.currentLetterIndex = 0
            self.currentMessageIndex += 1
            telemetryPlayer?.stop()

        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
  //      self.transmissionView.text = ""
        self.currentMessageIndex = 0
  //      telemetryPlayer?.play()
        self.receiveNewTelemetry(message: message1)
    }

}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

}
