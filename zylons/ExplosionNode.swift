//
//  ExplosionNode.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 10/27/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

class ExplosionNode: SCNNode {
    public var explosionDuration: Int = 0

    override init() {
        super.init()
        let explosionParticles = SCNParticleSystem(named: "Explosion", inDirectory: nil)
        explosionParticles?.emissionDuration = 0.3
        self.name = "explosionNode"
        self.addParticleSystem(explosionParticles!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
