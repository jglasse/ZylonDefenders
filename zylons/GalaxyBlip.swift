//
//  Blip.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 5/28/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import SceneKit

class GalaxyBlip: SCNNode {

    override init() {
        super.init()
        self.geometry =  SCNSphere.init(radius: Constants.galacticMapBlipRadius*2)
        }

    init(sectorType: SectorGridType) {
        super.init()
        self.opacity = 1
        self.name = "blip"
        switch sectorType {
        case .enemy,
             .enemy2,
             .enemy3:
                let newPlane = SCNPlane(width: 0.45, height: 0.45)
                newPlane.materials = [SCNMaterial()]
                newPlane.materials.first?.diffuse.contents = UIImage(named: "tieIconRed")
                newPlane.materials.first?.isDoubleSided = true
                self.geometry = blipIcon(type: "tieIconRed")
                self.opacity = 1.0
                self.rotation = SCNVector4(1, 0, 0, Float.pi/2)
                self.highlightNodeWithDurarion(1.0, .yellow, .red)
                let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 4)
                let forever = SCNAction.repeatForever(action)
                self.runAction(forever)

//                self.geometry =  SCNSphere.init(radius: Constants.galacticMapBlipRadius)
//                self.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//                self.highlightNodeWithDurarion(0.1, UIColor.yellow)
        case .starbase:
                self.opacity =  1.0
                self.geometry =  blipIcon(type: "spaceStation")
                self.rotation = SCNVector4(1, 1, 0, Float.pi/2)
                self.highlightNodeWithDurarion(0.2, .blue, .white)

                let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 4)
                let forever = SCNAction.repeatForever(action)
               // self.runAction(forever)
                //self.geometry?.firstMaterial?.emission.contents = UIColor.green

        default:
                break
        }

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func blipIcon(type: String) -> SCNGeometry {
        let newPlane = SCNPlane(width: 0.35, height: 0.35)
        newPlane.materials = [SCNMaterial()]
        newPlane.materials.first?.diffuse.contents = UIImage(named: type)
        newPlane.materials.first?.isDoubleSided = true
        return newPlane
    }

}

extension SCNNode {

    /// Creates A Pulsing Animation On An Infinite Loop
    ///
    /// - Parameter duration: TimeInterval
    func highlightNodeWithDurarion(_ duration: TimeInterval, _ color: UIColor, _ originalColor: UIColor) {

        //1. Create An SCNAction Which Emmits A Red Colour Over The Passed Duration Parameter
        let highlightAction = SCNAction.customAction(duration: duration) { (_, _) in
            let currentMaterial = self.geometry?.firstMaterial
            currentMaterial?.emission.contents = color
        }

        //2. Create An SCNAction Which Removes The Red Emissio Colour Over The Passed Duration Parameter
        let unHighlightAction = SCNAction.customAction(duration: duration) { (_, _) in
            let currentMaterial = self.geometry?.firstMaterial
            currentMaterial?.emission.contents = originalColor

        }

        //3. Create An SCNAction Sequence Which Runs The Actions
        let pulseSequence = SCNAction.sequence([highlightAction, unHighlightAction])

        //4. Set The Loop As Infinitie
        let infiniteLoop = SCNAction.repeatForever(pulseSequence)

        //5. Run The Action
        self.runAction(infiniteLoop)
    }

}
