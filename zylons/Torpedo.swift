//
//  Torpedo.swift
//  Zylon Defenders
//
//  Created by Jeffrey Glasse on 11/5/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SceneKit
enum TorpType {
    case humon
    case zylon
}

class Torpedo: SCNNode {

    public var age = 0
    public var torpType: TorpType = .zylon

    init(designatedTorpType: TorpType) {
        super.init()
        torpType = designatedTorpType
        self.geometry = SCNSphere(radius: 0.25)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        if torpType == .humon  //create humon torpedo
        {
        self.name = "Humon torpedo"
            self.physicsBody?.categoryBitMask = objectCategories.enemyFire
            self.physicsBody?.contactTestBitMask =  objectCategories.zylonShip
            let torpedoSparkle = SCNParticleSystem(named: "HumonTorpedo", inDirectory: "")
            self.addParticleSystem(torpedoSparkle!)

        } else // create zylon torpedo
        {
            self.name = "torpedo"
            self.physicsBody?.categoryBitMask = objectCategories.zylonFire
            self.physicsBody?.contactTestBitMask =  objectCategories.enemyShip
            let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
            self.addParticleSystem(torpedoSparkle!)
        }
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
