//
//   Kohai.swift
//  A class to handle all computer voice calls
//
//  Created by Jeff Glasse on 5/29/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import AVFoundation 

let numberstrings = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

class Kohai {
    
    private var voice: AVAudioPlayer!

    
    func speak(_ soundString: String) {
        print("envSound -  Soundstring: \(soundString)")
        if let soundURL = Bundle.main.url(forResource: soundString, withExtension: "m4a") { do {
            try voice =  AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("beepsound failed")
            }
            voice.volume = 0.5
            voice.play()
        }
    }
    
    
    
    
    
}



