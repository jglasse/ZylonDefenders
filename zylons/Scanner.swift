//
//  Scanner.swift
//  Zylon Defenders
//
//  Created by jglasse on 2/3/18.
//  Copyright © 2018 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit
class Blip: SCNNode {

}
class Scanner: SCNNode {
    var scannerTargets: [SCNNode]
    var numberOfSectorEnemies: Int {
        return scannerTargets.count
    }
    var scanBeam: SCNNode
    var sectorField: SCNNode

    override init() {
        let scannerScene = SCNScene(named: "Scanner.scn")
        sectorField = (scannerScene?.rootNode.childNodes[0])!
        scanBeam = (scannerScene?.rootNode.childNodes[1])!
        scannerTargets = [SCNNode]()
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

    func updateScanner(with sectorTargets: [SCNNode]) {
        scannerTargets.removeAll()
        for target in sectorTargets {
                let blip = SCNPyramid(width: 0.25, height: 0.25, length: 0.25)
                let blipSprite = Blip()
                blipSprite.geometry  = blip
                blipSprite.position = SCNVector3(target.worldPosition.x/500, target.worldPosition.x/500, target.worldPosition.x/500)
                blipSprite.geometry?.firstMaterial = SCNMaterial()
                blipSprite.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                blipSprite.name = "star"
                scannerTargets.append(blipSprite)

        }
    }
}
