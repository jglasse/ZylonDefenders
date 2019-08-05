//
//  MapTargetIndicator.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 6/1/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class MapTargetIndicator: SCNNode {
    // add the target and current position nodes
    init(color: UIColor) {
    super.init()
    self.opacity = 1.0
    self.geometry = SCNSphere(radius: Constants.galacticMapBlipRadius*4)
    self.geometry?.firstMaterial?.diffuse.contents = color
    let growAnim = SCNAction.scale(by: 3, duration: 1.0)
    let fadeAnim = SCNAction.fadeOut(duration: 1.0)
    let actions = [growAnim, fadeAnim]
    let growAndFade = SCNAction.group(actions)
    let reset = SCNAction.scale(to: 1.0, duration: 0)
    let reset2 = SCNAction.fadeIn(duration: 0)
    let resetActions = [reset, reset2]
    let shrinkAndMakeVisible = SCNAction.group(resetActions)
    let sequence = SCNAction.sequence([growAndFade, shrinkAndMakeVisible])
    let repeatedSequence = SCNAction.repeatForever(sequence)
    self.runAction(repeatedSequence)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
