//
//  GameScene.swift
//  POC-gekitai2
//
//  Created by Admin on 14/02/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var circle: SKShapeNode!
    private var square: SKShapeNode!
    var tileSet: SKTileSet!
    var tileMap: SKTileMapNode!
    
    private var currentNode: SKNode?
    
    
    override func didMove(to view: SKView) {
        addBoard()
        addCircle(x: 1000, y:300)
        addCircle(x: 1000, y:420)
    }
    
    func addCircle(x: Int, y: Int){
        circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .yellow
        circle.position = CGPoint(x: x, y: y)
        circle.name = "draggable"
        self.addChild(circle)
    }
    
    func addBoard() {
        let whiteTexture = SKTexture(imageNamed: "cell")
        
        let whiteTile = SKTileDefinition(texture: whiteTexture)
        let whiteTileGroup = SKTileGroup(tileDefinition: whiteTile)
        
        
        tileSet = SKTileSet(tileGroups: [whiteTileGroup], tileSetType: .grid)
        
        let tileSize = tileSet.defaultTileSize // from image size

        //let tileSize = CGSize(width: 100, height: 100)
        tileMap = SKTileMapNode(tileSet: tileSet, columns: 6, rows: 6, tileSize: tileSize)
        let tileGroup = tileSet.tileGroups.first
        tileMap.fill(with: tileGroup) // fill or set by column/row
        tileMap.anchorPoint = .zero
                
        self.addChild(tileMap)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.position(atPoint: t.location(in: self))
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let touchedNodes = self.nodes(at: location)
            for node in touchedNodes.reversed() {
                if node.name == "draggable" {
                    self.currentNode = node
                }
            }
        }
        
    }
    
    func position(atPoint pos: CGPoint){
        let column = tileMap.tileColumnIndex(fromPosition: pos)
        let row = tileMap.tileRowIndex(fromPosition: pos)
        let center = tileMap.centerOfTile(atColumn: column, row: row)
        print("\(column) - \(row) : center \(center)")
        
    }
    
    func centerTile(atPoint pos: CGPoint) -> CGPoint {
        let column = tileMap.tileColumnIndex(fromPosition: pos)
        let row = tileMap.tileRowIndex(fromPosition: pos)
        let center = tileMap.centerOfTile(atColumn: column, row: row)
        return center
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = self.currentNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //centraliza a peça no meio do espaço
        if let node = self.currentNode, let touch = touches.first  {
            let center = centerTile(atPoint: touch.location(in: self))
            node.position = center
        }
        
        //Finaliza a movimentação do drag and drop
        self.currentNode = nil
        
        //Printando a posição
        position(atPoint: (touches.first?.location(in: self))!)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
    
}
