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
        print("Humon Torpedo created")
        self.name = "Humon torpedo"
            self.physicsBody?.categoryBitMask = objectCategories.enemyFire
            self.physicsBody?.contactTestBitMask =  objectCategories.zylonShip
            let torpedoSparkle = SCNParticleSystem(named: "HumonTorpedo", inDirectory: "")
            self.addParticleSystem(torpedoSparkle!)

        } else // create zylon torpedo
        {
            self.name = "torpedo"
            self.physicsBody?.categoryBitMask = objectCategories.zylonFire
            self.physicsBody?.contactTestBitMask = objectCategories.zylonFire | objectCategories.enemyShip
            let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
            self.addParticleSystem(torpedoSparkle!)
        }
    }
//    override init() {
//    super.init()
//    let torpedoSparkle = SCNParticleSystem(named: "Torpedo", inDirectory: "")
//    self.geometry = SCNSphere(radius: 0.25)
//    self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//    self.physicsBody?.isAffectedByGravity = false
//    self.physicsBody?.categoryBitMask = objectCategories.enemyFire
//    self.physicsBody?.contactTestBitMask = objectCategories.zylonShip
//
//    self.name = "torpedo"
//    self.addParticleSystem(torpedoSparkle!)
//    }

    func fade(completion: () -> Void) {
        SCNTransaction.animationDuration = 1.0
        SCNTransaction.begin()
        self.opacity = 0
        SCNTransaction.commit()
        SCNTransaction.animationDuration = 0.0
        completion()
    }

    func decay() {
        self.age += 1
        if age > Constants.torpedoLifespan {
            self.fade(completion: {
                self.removeFromParentNode()
            })
//            let deadlineTime = DispatchTime.now() + .seconds(1)
//            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            self.removeFromParentNode()
//            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
