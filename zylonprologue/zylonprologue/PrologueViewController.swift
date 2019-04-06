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

class PrologueViewController: UIViewController, AVAudioPlayerDelegate {
    let writeInterval = 0.10
    let soundURL = Bundle.main.url(forResource: "telemetry2", withExtension: "aiff")

    lazy var telemetryTimer = Timer(timeInterval: writeInterval, target: self, selector: (#selector(self.advanceTelemetry)), userInfo: nil, repeats: true)
    var telemetryPlayer: AVAudioPlayer?
    var messageArray = [(message: String, delay: Float)]()
    var currentMessageIndex = 0
    var currentLetterIndex = 0
    var currentLetter = ""
    var existingTelemetry = ""
    var currentMessage: String?

    let message1 = """
Forty centons ago, they came -  spreading relentlessly
across peaceful Zylon systems like an unstoppable virus.

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

[TRANSMISSION 40AFFE TERMINATED]
"""

    @IBOutlet weak var starFieldView: UIImageView!
    @IBOutlet weak var transmissionView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTelemetryAudioPlayer()
    }

    func setupTelemetryAudioPlayer() {
        do {

            self.telemetryPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.telemetryPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.telemetryPlayer?.prepareToPlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageArray = [(message1, 1), (message2, 1), (message3, 1), (message4, 0)]

        self.currentMessageIndex = 0
        self.currentLetterIndex = 0
        self.displayNewTelemetry(message: message1)

    }

    func playTelemetrySound() {
        if (self.telemetryPlayer?.isPlaying)! {
        } else {
            self.telemetryPlayer?.play()
        }
    }

    @objc func advanceTelemetry() {

    }

    func receiveTelemetry(location: CGPoint, message: String, delay: Double) {
        var tempTelemetryTimer = Timer(timeInterval: delay, target: self, selector: (#selector(self.advanceTelemetry)), userInfo: nil, repeats: true)

    }
    func receive() {
        self.transmissionView.text = self.existingTelemetry
        self.currentLetterIndex += 1
        if let message = currentMessage {
           // currentLetter = message[currentLetterIndex]
        }
        self.existingTelemetry += String(currentLetter)

        if self.currentLetterIndex < self.message1.count-1 {
            self.playTelemetrySound()

        }
    }

    func displayNewTelemetry(message: String) {
        self.currentLetterIndex = 0
        let mainQ = DispatchQueue.main
        let  bgQ = DispatchQueue.global()
        let sleepamount = DispatchTime.now() + 0.5
        bgQ.sync {
        for letter in message {
            self.existingTelemetry += String(letter)
            print(letter)
            self.currentLetterIndex += 1
            mainQ.asyncAfter(deadline: sleepamount, execute: {
                self.transmissionView.text = self.existingTelemetry
            if self.currentLetterIndex < self.message1.count-1 {
                    self.playTelemetrySound()

            }
            })
            self.telemetryPlayer?.stop()
        }
        }}}

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