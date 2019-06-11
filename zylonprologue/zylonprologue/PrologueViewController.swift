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

class PrologueViewController: UIViewController, AVAudioPlayerDelegate, UIViewControllerTransitioningDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var transmissionView: UITextView!
    @IBOutlet weak var starFieldView: UIImageView!

    // MARK: - Vars
    var onPrologue = true
    let writeInterval = 0.01
    let soundURL = Bundle.main.url(forResource: "wopr", withExtension: "aiff")
    let musicURL = Bundle.main.url(forResource: "zylonHope", withExtension: "m4a")

    var telemetryTimer: Timer?
    
    var receievingMessage = false
    var telemetrySoundPlayer: AVAudioPlayer?
    var musicAudioPlayer: AVAudioPlayer?
    
    var messageArray = [(message: String, delay: Float)]()
    var currentMessage: String {
        return messageArray[currentMessageIndex].message
    }
    var currentMessageIndex = 0
    var currentLetterIndex = 0
    var currentLetter = ""
    var existingTelemetry = ""
    let message0 = "Forty centons ago, they arrived..."

    let message1 = " spreading relentlessly across peaceful Zylon systems like an unstoppable virus."
    let message1a = """


The STAR RAIDERS.
"""
    
    
    
    let message2 = """


With warp technology, they quickly established starbases deep within zylon space, conducting brutal raids which easily overwhelmed our defenses.
"""
    
    let message2a = " In just four cycles, a single raider defeated almost our entire defense force."


    let message3 = """


But a few brave scientists managed to develop an experimental starcruiser that could defeat the invaders - and finally drive them back to their distant homesystem, Sol.

"""
    let message3a = """

You will pilot that starship.
"""

    let message4a = """


DEFEND THE EMPIRE.
"""
    let message4b = " DRIVE BACK THE HUMON INVADERS."
    
    
    let message4c = """
 SAVE THE ZYLON RACE.


"""
let message5 = "[TRANSMISSION TERMINATED 40AFFE]"
    
    // MARK: - Lifecycle Funcs

    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageArray = [(message0, 0.75),(message1, 1),(message1a, 1), (message2, 1),(message2a, 1), (message3, 1),(message3a, 1.5),  (message4a, 0.85),(message4b, 0.85),(message4c, 1.3
            ),(message5, 1)]
        setupTelemetryAudioPlayer()
        setupMusicAudioPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.transmissionView.text = ""
        currentMessageIndex = 0


    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.musicAudioPlayer?.play()
        self.delayWithSeconds(2, completion: {
            self.telemetrySoundPlayer?.play()
            self.setupTimer()
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.musicAudioPlayer?.setVolume(0, fadeDuration: 1.5)
        self.musicAudioPlayer?.stop()
        self.onPrologue = false

    }
    
    
    // MARK: - Custom Funcs

    func setupTimer(){
        telemetryTimer = Timer.scheduledTimer(timeInterval: 0.031, target: self, selector: #selector(advanceTelemetry), userInfo: nil, repeats: true)
    }
    
    
    func setupMusicAudioPlayer() {
        do {
            
            self.musicAudioPlayer = try AVAudioPlayer(contentsOf: musicURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.musicAudioPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.musicAudioPlayer?.prepareToPlay()
    }

    func setupTelemetryAudioPlayer() {
        do {

            self.telemetrySoundPlayer = try AVAudioPlayer(contentsOf: soundURL!, fileTypeHint: AVFileType.aiff.rawValue)
            self.telemetrySoundPlayer?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        self.telemetrySoundPlayer?.numberOfLoops = 1000
        self.telemetrySoundPlayer?.prepareToPlay()
    }

    
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    @objc func advanceTelemetry() {
       // print("current Letter Index: \(self.currentLetterIndex)")
        if self.currentLetterIndex < currentMessage.count && onPrologue {
            let currentIndex = self.currentMessage.index(currentMessage.startIndex, offsetBy: currentLetterIndex)
            let newletter = self.currentMessage[currentIndex]
            transmissionView.text?.append(newletter)
            self.currentLetterIndex = self.currentLetterIndex + 1

        }
        else
        {
            telemetryTimer?.invalidate()
            let delay = messageArray[currentMessageIndex].delay
            messageArray.remove(at: 0)
            self.telemetrySoundPlayer?.stop()
            self.currentLetterIndex = 0
            self.delayWithSeconds(Double(delay)) {
                if self.messageArray.count > 0
                {
                self.setupTimer()
                self.telemetrySoundPlayer?.play()
                }
                else
                {
                    print("TRANSMISSIOM COMPLETED!")
                    // show continue button
                }
            }
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

