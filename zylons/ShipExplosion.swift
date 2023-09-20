//
//  ShipExplosion.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 11/5/17.
//  Copyright © 2023 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit

class ShipExplosion: SCNNode {
public var age = 0

    func update() {
        self.age += 1
    }

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

class ShieldExplosion: ShipExplosion {

    override init() {
        super.init()
        let explosionParticles = SCNParticleSystem(named: "ShieldTorpExplosion", inDirectory: nil)
        explosionParticles?.emissionDuration = 0.3
        self.name = "explosionNode"
        self.addParticleSystem(explosionParticles!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StationExplosion: ShipExplosion {
    override init() {
        super.init()
        let explosionParticles = SCNParticleSystem(named: "StationExplosion", inDirectory: nil)
        explosionParticles?.emissionDuration = 0.75
        self.name = "explosionNode"
        self.addParticleSystem(explosionParticles!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
