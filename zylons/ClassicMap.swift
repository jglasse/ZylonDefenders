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
    var targetSector: SKSpriteNode!
    var currentSector: SKSpriteNode!

    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        mapGrid =  Grid(blockSize: 32, rows: 8, cols: 16)
        mapGrid.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(mapGrid)
        targetSector = SKSpriteNode(color: .red, size: CGSize(width: 32, height: 32))
        currentSector = SKSpriteNode(color: .white, size: CGSize(width: 32, height: 32))
        targetSector.name = "keepMe"
        currentSector.name = "keepMe"
        targetSector.setScale(1.0)
        targetSector.position = mapGrid.gridPosition(row: 0, col: 2)
        targetSector.alpha = 0.4
        currentSector.alpha = 0.4

        mapGrid.addChild(targetSector)
        mapGrid.addChild(currentSector)

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
        let row = number / mapGrid.cols
        let column = (number) % mapGrid.cols
        return (row, column)

    }

    func mapGridFromSector(number: Int) -> CGPoint {
        let targ = convertToRows(number: number)
        return mapGrid.gridPosition(row: targ.0, col: targ.1)
    }

    func updateDisplay(galaxyModel: GalaxyMapModel, shipSector: Int, targetSector: Int) {

        // first, clear all non-indicators from the map
        for child in mapGrid.children where child.name != "keepMe" {child.removeFromParent()}

        // then iterate over each empty square, putting appropriate icons where they should appear

        for iLoop in 0...127 {
            var sectorIcon: SKSpriteNode?
            let currentSectorType = galaxyModel.map[iLoop].sectorType
            switch currentSectorType {
            case .enemy,
                 .enemy2,
                 .enemy3:
                sectorIcon = SKSpriteNode(imageNamed: "tieIconRed")
            case .empty:
                sectorIcon = nil
            case .starbase:
                sectorIcon = SKSpriteNode(imageNamed: "spaceStation")
            }
            if let icon = sectorIcon {

                icon.position = mapGridFromSector(number: iLoop)
                icon.size = CGSize(width: 24, height: 24)
                mapGrid.addChild(icon)
            }

        }
        setNewShipCurrentGrid(number: shipSector, color: .white)
        setNewTargetGrid(number: targetSector, color: .red)

    }

    func setNewShipCurrentGrid(number: Int, color: UIColor) {
        self.currentSector.position = mapGridFromSector(number: number)

    }

    func setNewTargetGrid(number: Int, color: UIColor) {
        self.targetSector.position = mapGridFromSector(number: number)
    }

}
