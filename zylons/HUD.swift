//
//  HUD.swift
//  Zylon Defenders
//
//  Created by Jeffery Glasse on 12/30/16.
//  Copyright © 2016 Jeffery Glasse. All rights reserved.
//

//
import UIKit
import SpriteKit
import AVFoundation

class HUD: SKScene
{
    var shields:SKShapeNode!
    var crosshairs:SKSpriteNode!
    var joystick:AnalogJoystick!
    
    override init(size: CGSize)
    {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        shields = SKShapeNode(rectOf: size)
        shields.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
        shields.alpha = 0.0
        shields.fillColor = SKColor.blue
        shields.strokeColor =  UIColor.clear


        self.addChild(shields)
        
        
        crosshairs=SKSpriteNode(imageNamed:"xenonHUD")
        crosshairs.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
        self.addChild(crosshairs)
        let joystick = AnalogJoystick(diameters: (70, 30), colors: (UIColor.green, UIColor.init(red: 0, green: 0, blue: 200, alpha: 100)))
    
        joystick.position = CGPoint(x: self.frame.midX/4, y: self.frame.midY - 70.0)
       // self.addChild(joystick)

        


    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

    }
    func toggleShields(){
        
        
        if (shields.alpha > 0)
        { shields.alpha = 0
        
        }
        else
        { shields.alpha = 0.2 }
        
        
    
    }
    
}
