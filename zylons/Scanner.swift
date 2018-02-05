//
//  Scanner.swift
//  Zylon Defenders
//
//  Created by jglasse on 2/3/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class Scanner: SCNNode {
    var numberOfSectorEnemies = 0
    var scanBeam: SCNNode
    var sectorField: SCNNode

    override init() {
        let scannerScene = SCNScene(named: "Scanner.scn")
        sectorField = (scannerScene?.rootNode.childNodes[0])!
        scanBeam = (scannerScene?.rootNode.childNodes[1])!
        super.init()
        self.addChildNode(sectorField)
        self.addChildNode(scanBeam)
        scanBeam.opacity = 0.75
        self.name = "scanner"
        self.worldPosition = SCNVector3(5, 5, -10)
        self.scale = SCNVector3Make(1, 1, 1)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
