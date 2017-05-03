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
import SceneKit

class HUD: SKScene
{
    var shields:SKShapeNode!
    var crosshairs:SKSpriteNode!
    var myscene: GameViewController?
    var computerStatus = SKLabelNode()
    public var joystick:AnalogJoystick!
    var timer: Timer?
    
    
    
    
    func updateComputerDisplay() {
        if computerStatus.fontColor == UIColor.red
        {computerStatus.fontColor = UIColor.clear}
            else
        {computerStatus.fontColor = UIColor.red}
    
    
    }
    override init(size: CGSize)
    {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        shields = SKShapeNode(rectOf: size)
        shields.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
        shields.alpha = 0.0
        shields.fillColor = SKColor.blue
        shields.strokeColor =  UIColor.clear
        computerStatus.fontName = "Y14.5M 17.0"
        computerStatus.fontSize = 9
        computerStatus.fontColor = UIColor.red
        computerStatus.position = CGPoint(x: self.frame.midX/4, y: self.frame.midY + 110.0)
        computerStatus.text = "GRIDWARP ENGINES OFFLINE"
        

        self.addChild(shields)
        
        
        crosshairs=SKSpriteNode(imageNamed:"xenonHUD")
        crosshairs.position = CGPoint(x:self.frame.midX, y: self.frame.midY+10)
        self.addChild(crosshairs)
        let joystick = AnalogJoystick(diameters: (70, 30), colors: (UIColor.green, UIColor.init(red: 0, green: 0, blue: 200, alpha: 100)))
    
        joystick.position = CGPoint(x: self.frame.midX/4, y: self.frame.midY - 70.0)
        self.addChild(joystick)
        self.addChild(computerStatus)
        self.scheduleTimer()
        
        
        
      
            
        
        
     
      
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

    }
    
    func scheduleTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(self.updateComputerDisplay), userInfo: nil, repeats: true)
        }
    }
    
    func toggleShields(){
        
        
        if (shields.alpha > 0)
        { shields.alpha = 0
        
        }
        else
        { shields.alpha = 0.2 }
        
        
    
    }
    
}
