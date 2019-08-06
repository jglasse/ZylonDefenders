//
//  TelemetryPlayer.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 7/22/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class TelemetryPlayer: UITextView, AVAudioPlayerDelegate {
    private var isWriting = false
    private var currentLetterIndex = 0
    private var currentLetter = ""
    private var currentMessage = ""
    private var cursorIsVisitble = false
    private var telemetryTimer: Timer?
    private var blinkTimer: Timer?
    private var telemetrySoundPlayer: AVAudioPlayer?

    private let soundURL = Bundle.main.url(forResource: "wopr", withExtension: "aiff")

    func writeMessage(message: String, speed: Double = 0.097 ) {
        if isWriting {
            telemetryTimer?.invalidate()
            isWriting = false
        }
        self.telemetrySoundPlayer?.play()
        self.text = ""
        blinkTimer?.invalidate()
        cursorIsVisitble = false
        currentLetterIndex = 0
        currentLetter = ""
        currentMessage = message
        setupTimer(speed: speed)
    }

    func fadeout() {
        UIView.animate(withDuration: 1.0, animations: {self.alpha = 0})
        
    }
    private func setupTimer(speed: Double) {
        telemetryTimer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(advanceTelemetry), userInfo: nil, repeats: true)
    }

    private func setupBlinkTimer(speed: Double = 0.12) {
        blinkTimer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(blinkCursor), userInfo: nil, repeats: true)
    }

    @objc func blinkCursor() {
        switch cursorIsVisitble {
        case true:
            self.text.removeLast()
            cursorIsVisitble = false
        case false:
            self.text.append(Character("_"))
            cursorIsVisitble = true

        }

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

    @objc func advanceTelemetry() {
        // print("current Letter Index: \(self.currentLetterIndex)")
        if self.currentLetterIndex < currentMessage.count {
            let currentIndex = self.currentMessage.index(currentMessage.startIndex, offsetBy: currentLetterIndex)
            let newletter = self.currentMessage[currentIndex]
            self.text?.append(newletter)
            self.currentLetterIndex += 1

        } else {
            telemetryTimer?.invalidate()
            self.telemetrySoundPlayer?.stop()
            self.currentLetterIndex = 0
            self.setupBlinkTimer()
        }
    }
}
