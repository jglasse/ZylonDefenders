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
    @IBOutlet weak var starFieldBG: UIImageView!
    @IBOutlet weak var progressButton: UIButton!
    
    // MARK: - Vars
    var prologueViewed = false
    var onPrologue = true
    let writeInterval = 0.037
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
    let message0 = "Forty centons ago, they arrived"

    let message1 = """
...spreading relentlessly across peaceful Zylon
systems like an unstoppable virus.
"""
    let message1a = """


The STAR RAIDERS.
"""
    
    
    
    let message2 = """


With warp technology, they quickly established starbases deep within Zylon space,
conducting brutal raids which easily overwhelmed our defenses.
"""
    
    let message2a =  """
 In just four cycles,
a single raider defeated almost our entire defense force.
"""


    let message3 = """


But a few brave scientists managed to develop an experimental starcruiser that could
defeat the invaders - and finally drive them back to their distant homesystem, Sol.

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
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            
            
            ////If your plist contain root as Dictionary
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let x = dic["PrologueViewed"] as? Bool {
                    self.prologueViewed = x
                    print("PrologueViewed = \(self.prologueViewed)")
                }
            }
        }
        
        messageArray = [(message0, 0.75),(message1, 1.20),(message1a, 1.55), (message2, 1),(message2a, 1), (message3, 1.25),(message3a, 1.5),  (message4a, 0.5),(message4b, 0.5),(message4c, 0.75
            ),(message5, 0)]
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
        UIView.animate(withDuration: 3.75, animations: {
            self.starFieldBG.alpha = 1.0
        })
        UIView.animate(withDuration: 48.75, delay: 0, options: .curveLinear, animations: {
            self.starFieldBG.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        }, completion: nil)

        self.delayWithSeconds(2.85, completion: {
            self.telemetrySoundPlayer?.play()
            self.setupTimer()
            UIView.animate(withDuration: 1.25, animations: {
                self.progressButton.alpha = 0.75
                
            })
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
        telemetryTimer = Timer.scheduledTimer(timeInterval: writeInterval, target: self, selector: #selector(advanceTelemetry), userInfo: nil, repeats: true)
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
                if self.messageArray.count > 0  // if there are still messages left to receive, receive them
                {
                self.setupTimer()
                self.telemetrySoundPlayer?.play()
                }
                else //otherwise, finish things up 
                {
                    self.delayWithSeconds(6, completion: {self.fadeout()})
                    // show continue button
                }
            }
        }
    }

    func fadeout() {
        UIView.animate(withDuration: 2, animations: {
            self.transmissionView.alpha = 0.0
        })
        UIView.animate(withDuration: 4, animations: {
            self.starFieldBG.alpha = 0.0
        })
        self.delayWithSeconds(2.85, completion: {
            self.telemetrySoundPlayer?.stop()
            self.musicAudioPlayer?.setVolume(0, fadeDuration: 2.0)
        })
        self.delayWithSeconds(4, completion: {
            // go to gameplay screen
        })
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




