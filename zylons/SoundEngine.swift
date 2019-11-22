//
//  SoundEngine.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 11/21/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import AVFoundation

extension ZylonGameViewController {
  func computerBeepSound(_ soundString: String) {
    print("computerBeepSound called")
       if let soundURL = Bundle.main.url(forResource: soundString, withExtension: "mp3") { do {
        print("soundURL defined")
           try beepsound =  AVAudioPlayer(contentsOf: soundURL)
            beepsound.volume = 0.5
            beepsound.play()
       } catch {
           print("beepsound failed")
           }
       }
    }
}
