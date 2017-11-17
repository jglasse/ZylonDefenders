//
//  TorpedoNode.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 11/5/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

class TorpedoNode: SCNNode {

    override init() {
        super.init()
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        self.name = "torpedo"
        self.physicsBody?.categoryBitMask = 0b00000010
        self.physicsBody?.contactTestBitMask = 0b00000010

        let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
        self.addParticleSystem(torpedoSparkle!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
