//
//  GameScene.swift
//  POC-gekitai2
//
//  Created by Admin on 14/02/23.
//

import SpriteKit
import GameplayKit
import Foundation

struct Piece: Equatable {
    enum Color {
        case blue
        case yellow
    }
    
    var node: SKShapeNode
    var column: Int
    var row: Int
    var x: Double
    var y: Double
    let color: Color
}

class GameScene: SKScene {
    
    private var circle: SKShapeNode!
    var tileSet: SKTileSet!
    var tileMap: SKTileMapNode!
    
    private var currentNode: SKNode?
    private var lastPosNode: CGPoint?
    
    var previousPos: Index?
    var newPos: Index?
    
    var pieces: [Piece] = []
    
    override func didMove(to view: SKView) {
        addBoard()
        
        addPiece(x: 140.0, y: 120.0, .yellow)
        addPiece(x: 200.0, y: 120.0, .yellow)
        addPiece(x: 260.0, y: 120.0, .yellow)
        addPiece(x: 320.0, y: 120.0, .yellow)
        addPiece(x: 380.0, y: 120.0, .yellow)
        addPiece(x: 440.0, y: 120.0, .yellow)
        addPiece(x: 500.0, y: 120.0, .yellow)
        addPiece(x: 560.0, y: 120.0, .yellow)
        
        addPiece(x: 140.0, y: 680.0, .blue)
        addPiece(x: 200.0, y: 680.0, .blue)
        addPiece(x: 260.0, y: 680.0, .blue)
        addPiece(x: 320.0, y: 680.0, .blue)
        addPiece(x: 380.0, y: 680.0, .blue)
        addPiece(x: 440.0, y: 680.0, .blue)
        addPiece(x: 500.0, y: 680.0, .blue)
        addPiece(x: 560.0, y: 680.0, .blue)
        
        
    }
    
    func addPiece(x: Double, y: Double, _ color: UIColor){
        circle = SKShapeNode(circleOfRadius: 20)
        circle.fillColor = color
        circle.position = CGPoint(x: x, y: y)
        circle.name = "draggable"
        //self.addChild(circle)
        self.tileMap.addChild(circle)
        
        var colorPiece: Piece.Color
        if color == .yellow {
            colorPiece = .yellow
        } else {
            colorPiece = .blue
        }
        self.pieces.append(Piece(node: circle, column: -1, row: -1,x: x, y: y, color: colorPiece))
    }
    
    func removePiece(from origin: Piece) {
        // remover piece.node da board
        // remover piece do pieces
        //let center = tileMap.centerOfTile(atColumn: index.column, row: index.row)
        origin.node.removeFromParent()
        guard let pieceIndex = pieces.firstIndex(of: origin) else { return }
        pieces.remove(at: pieceIndex)
    }
    
    func findPiece(from index: Index) -> Piece? {
        // buscar piece que ta no index (no pieces)
        if index.column > 5 || index.row > 5 || index.column < 0 || index.row < 0 {
            
            let node = tileMap.nodes(at: CGPoint(x: 140.0, y: 680.0))
            for i in pieces.indices {
                if pieces[i].node == node.first {
                    return pieces[i]
                }
            }
        }
        
        for piece in pieces where piece.column == index.column && piece.row == index.row {
            return piece
        }
        return nil
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
        tileMap.anchorPoint = .init(x: -0.23, y: -0.33)
        
        self.addChild(tileMap)
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
    
    func movePiece(originIndex: Index, newIndex: Index) {
        // buscar piece que ta no index (no pieces)
        let pieceOrigin = findPiece(from: originIndex)
        
        
        /// Alternativa 1
        // removeCircle
        // remover piece.node da board
        // remover piece do pieces
        guard let piece = pieceOrigin else { return }
        removePiece(from: piece)
        
        var color: UIColor
        if pieceOrigin?.color == .yellow {
            color = .yellow
        } else {
            color = .blue
        }
        
        // adicionar de novo, com cor do que foi removido, e posicao nova (addCircle)
        let center = tileMap.centerOfTile(atColumn: newIndex.column, row: newIndex.row)
        addPiece(x: center.x, y: center.y, color)
    
        
        /// Alternativa 2
        // piece.node.removeFromParent
        // mudar posicao do node da piece pra nova posicao
        // mudar posicao da piece em si (x e y) para nova posicao
        // adicionar a piece de novo na board
        // :)
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = self.nodes(at: location)
            for node in touchedNodes.reversed() {
                if node.name == "draggable" {
                    self.currentNode = node
                    self.lastPosNode = node.position
                    
                    let position = touch.location(in: self)
                    let column = tileMap.tileColumnIndex(fromPosition: position)
                    let row = tileMap.tileRowIndex(fromPosition: position)
                    self.previousPos = Index(row: row, column: column)
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = self.currentNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //centraliza a peça no meio do espaço
        if let node = self.currentNode, let touch = touches.first {
            
            let position = touch.location(in: self)
            let column = tileMap.tileColumnIndex(fromPosition: position)
            let row = tileMap.tileRowIndex(fromPosition: position)
            self.newPos = Index(row: row, column: column)
            if column < 0 || column > 5 || row < 0 || row > 5 {
                
                //node.position = lastPosNode ?? CGPoint.zero
                
            } else {
                let center = centerTile(atPoint: position)
                node.position = center
                
                for i in pieces.indices {
                    if pieces[i].node == node {
                        pieces[i].column = column
                        pieces[i].row = row
                    }
                }
                
            }
            
            
            
        }
        
        //Finaliza a movimentação do drag and drop
        self.currentNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
    
    
}
