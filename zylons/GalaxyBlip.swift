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
    
    init(sectorType: SectorType) {
        super.init()
        self.opacity = 1
        switch sectorType {
            case .enemy:
                self.geometry =  SCNSphere.init(radius: Constants.galacticMapBlipRadius)
                self.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                self.highlightNodeWithDurarion(0.1, UIColor.black)
            case .starbase:
                self.geometry =  SCNPyramid.init(width: Constants.galacticMapBlipRadius*4
                    , height: Constants.galacticMapBlipRadius*4, length: Constants.galacticMapBlipRadius*4)
                self.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            case .empty:
                break
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension SCNNode{
    
    /// Creates A Pulsing Animation On An Infinite Loop
    ///
    /// - Parameter duration: TimeInterval
    func highlightNodeWithDurarion(_ duration: TimeInterval, _ color: UIColor){
        
        //1. Create An SCNAction Which Emmits A Red Colour Over The Passed Duration Parameter
        let highlightAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            
           // let color = UIColor(red: elapsedTime/CGFloat(duration), green: 0, blue: 0, alpha: 1)
            let currentMaterial = self.geometry?.firstMaterial
            currentMaterial?.emission.contents = color
            
        }
        
        //2. Create An SCNAction Which Removes The Red Emissio Colour Over The Passed Duration Parameter
        let unHighlightAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            let color = UIColor(red: CGFloat(1) - elapsedTime/CGFloat(duration), green: 0, blue: 0, alpha: 1)
            let currentMaterial = self.geometry?.firstMaterial
            currentMaterial?.emission.contents = color
            
        }
        
        //3. Create An SCNAction Sequence Which Runs The Actions
        let pulseSequence = SCNAction.sequence([highlightAction, unHighlightAction])
        
        //4. Set The Loop As Infinitie
        let infiniteLoop = SCNAction.repeatForever(pulseSequence)
        
        //5. Run The Action
        self.runAction(infiniteLoop)
    }
    
}


