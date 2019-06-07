//
//  Scanner.swift
//  Zylon Defenders
//  SCNNode which 

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
        scanBeam.opacity = 0.55

        if let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur") {
            gaussianBlurFilter.name = "blur"
            gaussianBlurFilter.setValue(5, forKey: kCIInputRadiusKey)
            scanBeam.filters = [gaussianBlurFilter]

        }
        self.name = "scanner"
        self.worldPosition = SCNVector3(5, 5, -10)
        self.scale = SCNVector3Make(1, 1, 1)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateScanner(with sectorTargets: [SCNNode]) {
        scannerTargets.removeAll()
        for oldtarget in sectorField.childNodes {
            if oldtarget.name == "blip" {
            oldtarget.removeFromParentNode()
            }
        }
        for target in sectorTargets {
                let blip = SCNPyramid(width: 0.15, height: 0.15, length: 0.15)
                let blipSprite = SCNNode()
                blipSprite.geometry  = blip
                blipSprite.position = SCNVector3(target.worldPosition.x/100, target.worldPosition.y/90, target.worldPosition.z/90)
                blipSprite.geometry?.firstMaterial = SCNMaterial()
                blipSprite.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                blipSprite.name = "blip"
                sectorField.addChildNode(blipSprite)
                scannerTargets.append(blipSprite)

        }
    }
}
