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
    let writeInterval = 0.01
    let soundURL = Bundle.main.url(forResource: "telemetry2", withExtension: "aiff")

    var telemetryTimer = Timer(timeInterval: writeInterval, target: self, selector: (#selector(self.advanceTelemetry)), userInfo: nil, repeats: true)
    var receievingMessage = false
    var telemetrySoundPlayer: AVAudioPlayer?
      messageArray = [(message: String, delay: Float)]()
    var currentMessageIndex = 0
    var currentLetterIndex = 0
    var currentLetter = ""
    var existingTelemetry = ""
    var currentMessage = ""

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

            self.telemetrySoundPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.telemetrySoundPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.telemetrySoundPlayer?.prepareToPlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageArray = [(message1, 1), (message2, 1), (message3, 1), (message4, 0)]

        self.receiveTelemetry(location: 0, 0, message: message1)

    }

    func playTelemetrySound() {
        if (self.telemetrySoundPlayer?.isPlaying)! {
        } else {
            self.telemetrySoundPlayer?.play()
        }
    }

    @objc func advanceTelemetry() {

    }

    func receiveTelemetry(location: CGPoint, message: String) {

    }

        })
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
