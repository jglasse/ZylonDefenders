//
//  Torpedo.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 11/5/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import SceneKit

class Torpedo: SCNNode {
    public var age = 0

    override init() {
    super.init()
    self.geometry = SCNSphere(radius: 0.25)
    self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    self.physicsBody?.isAffectedByGravity = false
    self.name = "torpedo"
    self.physicsBody?.categoryBitMask = 0b00000010
    self.physicsBody?.contactTestBitMask = 0b00000010
    let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
    self.addParticleSystem(torpedoSparkle!)
    }

    func fade() {
        SCNTransaction.animationDuration = 1.0
        SCNTransaction.begin()
        self.opacity = 0
        SCNTransaction.commit()
        SCNTransaction.animationDuration = 0.0

    }

    func decay() {
        self.age += 1
        if age > Constants.torpedoLifespan {
            self.fade()
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.removeFromParentNode()
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
