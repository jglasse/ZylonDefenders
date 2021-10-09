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
    private var cursorIsVisible = false
    private var telemetryTimer: Timer?
    private var blinkTimer: Timer?
    private var telemetrySoundPlayer: AVAudioPlayer?
    private var telemetryStopped = false
  

    private let soundURL = Bundle.main.url(forResource: "wopr", withExtension: "aiff")

    func writeMessage(message: String, speed: Double = 0.097 ) {
        blinkTimer?.invalidate()
        telemetryTimer?.invalidate()
        isWriting = true
        self.telemetrySoundPlayer?.play()
        self.text = ""
        self.isHidden = false
        self.alpha = 1.0
        blinkTimer?.invalidate()
        cursorIsVisible = false
        currentLetterIndex = 0
        currentLetter = ""
        currentMessage = message
        setupTimer(speed: speed)
    }

    func abort() {
        self.telemetrySoundPlayer?.stop()
        telemetryTimer?.invalidate()
        blinkTimer?.invalidate()
        self.text = ""
        isWriting = false
        self.telemetryStopped = true
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
        switch cursorIsVisible {
        case true:
            if self.text.count>0 {self.text.removeLast()}
            cursorIsVisible = false
        case false:
            self.text.append(Character("_"))
            cursorIsVisible = true

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
        if !telemetryStopped {
        if currentLetterIndex < currentMessage.count && isWriting {
            let currentIndex = self.currentMessage.index(currentMessage.startIndex, offsetBy: currentLetterIndex)
            let newletter = self.currentMessage[currentIndex]
            self.text?.append(newletter)
            self.currentLetterIndex += 1

        } else {
            telemetryTimer?.invalidate()
            self.telemetrySoundPlayer?.stop()
            self.currentLetterIndex = 0
            self.setupBlinkTimer()
            isWriting = false
        }
        } else {
            abort()
        }
    }
}
