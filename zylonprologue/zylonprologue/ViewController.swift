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
    let soundURL = Bundle.main.url(forResource: "telemetry2", withExtension: "aiff")

    var telemetryPlayer: AVAudioPlayer?

    var currentMessageIndex = 0
    var currentLetterIndex = 0

    var currentLetter = ""
    var existingTelemetry = ""
    var currentMessage = ""

    let message1 = """
Over forty centons ago, they came -  spreading relentlessly
across peaceful zylon systems like an unstoppable virus.

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

//      let telemetryTimer = Timer(timeInterval: 0.1, target: self, selector: (#selector(self.advanceTelemetry)), userInfo: nil, repeats: true)

    @IBOutlet weak var starFieldView: UIImageView!
    @IBOutlet weak var transmissionView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageArray = [(message1, 1), (message2, 1), (message3, 1), (message4, 0)]

        self.currentMessageIndex = 0
        self.currentLetterIndex = 0
        self.receiveNewTelemetry(message: message1)
    }

    func playTelemetrySound() {
        if (self.telemetryPlayer?.isPlaying)! {
            return
        } else {
            self.telemetryPlayer?.play()
        }

    }

    @objc func advanceTelemetry() {

    }
    func receiveNewTelemetry(message: String) {
        let backgroundQ = DispatchQueue(label: "bgQ", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        self.currentLetterIndex = 0
        do {
            let soundURL = Bundle.main.url(forResource: "telemetry2", withExtension: "aiff")

            self.telemetryPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.telemetryPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.telemetryPlayer?.prepareToPlay()
        let mainQ = DispatchQueue.main
        let sleepamount = DispatchTime.now() + 1
        backgroundQ.async {
        for letter in message {
            self.existingTelemetry += String(letter)
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
