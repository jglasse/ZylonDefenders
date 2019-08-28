//
//  ClassicMap.swift
//  Zylon Defenders
//
//  Created by Jeff Glasse on 8/27/19.
//  Copyright © 2019 Jeffery Glasse. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class ClassicMap: SKScene {
    var mapGrid: Grid!
    var targetSector:SKSpriteNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        mapGrid =  Grid(blockSize: 32, rows: 8, cols: 16)
        mapGrid.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(mapGrid)
        targetSector = SKSpriteNode(color: .red, size: CGSize(width: 32 ,height: 32))
        // let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
        targetSector.setScale(1.0)
        targetSector.position = mapGrid.gridPosition(row: 0, col: 2)
        mapGrid.addChild(targetSector)
        
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    func highlightAlpha() {
        
    print("classic Alpha")
        
    }
    func highlightBeta() {
        
        print("classic Beta")
        
    }
    
    func convertToRows(number: Int) -> (Int, Int) {
        var row = 0
        switch number {
        case 0...15:
            row = 0
        case 16...31:
            row = 1
        case 32...47:
            row = 2
        case 48...63:
            row = 3
        case 64...79:
            row = 4
        case 80...95:
            row = 5
        case 96...111:
            row = 6
        default:
            row = 7
        }
        let column = (number) % 16
        
        return (row,column)
        
    }
    
    func mapGridFromSector(number: Int) -> CGPoint {
        let targ = convertToRows(number: number)
        return mapGrid.gridPosition(row: targ.0, col: targ.1)
    }
    
    func updateDisplay(galaxyModel: GalaxyMapModel, shipSector: Int, targetSector:Int) {
        //iterate over grids, putting appropriate icons where they should be
      //  mapGrid.removeAllChildren()
        for i in 0...127 {
            var sectorIcon: SKSpriteNode?
            let currentSectorType = galaxyModel.map[i].sectorType
            switch currentSectorType  {
            case .enemy:
                sectorIcon = SKSpriteNode(imageNamed: "tieIconRed")
            case .empty:
                sectorIcon = nil
            case .starbase:
                sectorIcon = SKSpriteNode(imageNamed: "spaceStation")
            }
            if let icon = sectorIcon {

                icon.position = mapGridFromSector(number: i)
                icon.size = CGSize(width: 24, height: 24)
                mapGrid.addChild(icon)
            }
            
        }
        setNewShipCurrentGrid(number: shipSector, color: .white)
        setNewTargetGrid(number: targetSector, color: .red)
        
    }
    
    func setNewShipCurrentGrid(number: Int, color: UIColor) {
        
    }
    
    func setNewTargetGrid(number: Int, color: UIColor) {
        self.targetSector.position = mapGridFromSector(number: number)
    }
    
}
