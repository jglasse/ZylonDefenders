//
//  PrologueViewController.swift
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
    let soundURL = Bundle.main.url(forResource: "wopr", withExtension: "aiff")
    var telemetryTimer: Timer?
    
    var receievingMessage = false
    var telemetrySoundPlayer: AVAudioPlayer?
    
    var messageArray = [(message: String, delay: Float)]()
    var currentMessage: String {
        return messageArray[currentMessageIndex].message
    }
    var currentMessageIndex = 0
    var currentLetterIndex = 0
    var currentLetter = ""
    var existingTelemetry = ""
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
starcruiser that could defeat the invaders - and
finally drive them back to their distant homesystem, Sol.

You will pilot that starship.
"""
    let message4 = """

DEFEND THE EMPIRE. DRIVE BACK THE HUMON INVADERS. SAVE THE ZYLON RACE.

[TRANSMISSION TERMINATED 40AFFE]
"""

    @IBOutlet weak var starFieldView: UIImageView!
    @IBOutlet weak var transmissionView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageArray = [(message1, 1), (message2, 1), (message3, 1), (message4, 0)]
        setupTelemetryAudioPlayer()
        telemetryTimer = Timer.scheduledTimer(timeInterval: 0.031, target: self, selector: #selector(advanceTelemetry), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        currentMessageIndex = 0
        self.telemetrySoundPlayer?.play()
        self.transmissionView.text = ""
        
        
    }
    

    func setupTelemetryAudioPlayer() {
        do {

            self.telemetrySoundPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.telemetrySoundPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.telemetrySoundPlayer?.numberOfLoops = currentMessage.count
        self.telemetrySoundPlayer?.prepareToPlay()
    }

 
    
    @objc func advanceTelemetry() {
       // print("current Letter Index: \(self.currentLetterIndex)")
        if self.currentLetterIndex < currentMessage.count {
            let currentIndex = self.currentMessage.index(currentMessage.startIndex, offsetBy: currentLetterIndex)
            let newletter = self.currentMessage[currentIndex]
            transmissionView.text?.append(newletter)
            self.currentLetterIndex = self.currentLetterIndex + 1

        }
        else
        {
            telemetryTimer?.invalidate()
            messageArray.remove(at: 0)
            print(messageArray.description)
        }
    }

}



extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
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

