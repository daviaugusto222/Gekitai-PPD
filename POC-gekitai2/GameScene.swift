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
    
    var node: SKSpriteNode
    let xOrigin: Double
    let yOrigin: Double
    let color: Color
}

class GameScene: SKScene {
    
    private var circle: SKShapeNode!
    var tileSet: SKTileSet!
    var tileMap: SKTileMapNode!
    
    private var currentNode: SKNode?
    
    var previousPos: PositionPiece?
    var newPos: PositionPiece?
    
    var pieces: [Piece] = []
    var movesPices: [Move] = []
    
    var originYellowPositions: [PositionPiece] = []
    var originBluePositions: [PositionPiece] = []
    
    override func didMove(to view: SKView) {
        
        
        
        
        originYellowPositions = [PositionPiece(row: 140.0, column: 120.0),
                                 PositionPiece(row: 200.0, column: 120.0),
                                 PositionPiece(row: 260.0, column: 120.0),
                                 PositionPiece(row: 320.0, column: 120.0),
                                 PositionPiece(row: 380.0, column: 120.0),
                                 PositionPiece(row: 440.0, column: 120.0),
                                 PositionPiece(row: 500.0, column: 120.0),
                                 PositionPiece(row: 560.0, column: 120.0)]
        
        originBluePositions = [PositionPiece(row: 140.0, column: 680.0),
                               PositionPiece(row: 200.0, column: 680.0),
                               PositionPiece(row: 260.0, column: 680.0),
                               PositionPiece(row: 320.0, column: 680.0),
                               PositionPiece(row: 380.0, column: 680.0),
                               PositionPiece(row: 440.0, column: 680.0),
                               PositionPiece(row: 500.0, column: 680.0),
                               PositionPiece(row: 560.0, column: 680.0)]
        
        addBoard()
        
        for pos in originYellowPositions {
            addPiece(x: pos.row, y: pos.column, .yellow)
        }
        for pos in originBluePositions {
            addPiece(x: pos.row, y: pos.column, .blue)
        }
    }
    
    func addPiece(x: Double, y: Double, _ color: UIColor){
        //circle = SKShapeNode(circleOfRadius: 20)
        //circle.fillColor = color
        
        
        var image = UIImage(named: "bottom")
        var node = SKSpriteNode()
        var colorPiece: Piece.Color
        if color == .yellow {
            colorPiece = .yellow
            image = UIImage(named: "bottom")
        } else {
            colorPiece = .blue
            image = UIImage(named: "top")
        }
        
        let texture = SKTexture(image: image!)
        node = SKSpriteNode(texture: texture)
        
        node.position = CGPoint(x: x, y: y)
        node.name = "draggable"
        self.tileMap.addChild(node)
        
        
        self.pieces.append(Piece(node: node, xOrigin: x, yOrigin: y, color: colorPiece))
    }
    
    func removePiece(from origin: Piece) {
        // remover piece.node da board
        // remover piece do pieces
        origin.node.removeFromParent()
        guard let pieceIndex = pieces.firstIndex(of: origin) else { return }
        pieces.remove(at: pieceIndex)
    }
    
    func findPiece(from pos: PositionPiece) -> Piece? {
        // buscar piece que ta no index (no pieces)
        for piece in pieces where piece.node.position.x == pos.row && piece.node.position.y == pos.column {
            return piece
        }
        return nil
    }
    
    func addBoard() {
        let whiteTexture = SKTexture(imageNamed: "regia")
        let whiteTile = SKTileDefinition(texture: whiteTexture)
        let whiteTileGroup = SKTileGroup(tileDefinition: whiteTile)
        tileSet = SKTileSet(tileGroups: [whiteTileGroup], tileSetType: .grid)
        let tileSize = tileSet.defaultTileSize // from image size
        tileMap = SKTileMapNode(tileSet: tileSet, columns: 6, rows: 6, tileSize: tileSize)
        let tileGroup = tileSet.tileGroups.first
        tileMap.fill(with: tileGroup) // fill or set by column/row
        tileMap.anchorPoint = .init(x: -0.23, y: -0.33)
        
        self.addChild(tileMap)
    }
    
    func centerTile(atPoint pos: CGPoint) -> CGPoint {
        let column = tileMap.tileColumnIndex(fromPosition: pos)
        let row = tileMap.tileRowIndex(fromPosition: pos)
        let center = tileMap.centerOfTile(atColumn: column, row: row)
        return center
    }
    
    func movePiece(originPos: PositionPiece, newPos: PositionPiece) {
        if let piece = findPiece(from: originPos) {
            //animateNodes(piece.node, pos: newPos)
            piece.node.position = CGPoint(x: newPos.row, y: newPos.column)
        }
        
//          Moviventação complexa porém desnecessária
//        let pieceOrigin = findPiece(from: originPos)
//
//        guard let piece = pieceOrigin else { return }
//        removePiece(from: piece)
//
//        var color: UIColor
//        if pieceOrigin?.color == .yellow {
//            color = .yellow
//        } else {
//            color = .blue
//        }
//
//        let position = piece.node.position
//        let column = tileMap.tileColumnIndex(fromPosition: position)
//        let row = tileMap.tileRowIndex(fromPosition: position)
//
//        if column < 0 || column > 5 || row < 0 || row > 5  {
//            addPiece(x: newPos.x, y: newPos.y, color)
//        } else {
//
//            let center = centerTile(atPoint: CGPoint(x: newPos.x, y: newPos.y))
//            addPiece(x: center.x, y: center.y, color)
//        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = self.nodes(at: location)
            for node in touchedNodes.reversed() {
                if node.name == "draggable" {
                    self.currentNode = node
                    self.previousPos = PositionPiece(row: node.position.x, column: node.position.y)
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
            
            //Apartir da posição do node encontra linha e coluna
            let position = touch.location(in: self)
            let column = tileMap.tileColumnIndex(fromPosition: position)
            let row = tileMap.tileRowIndex(fromPosition: position)
            let center = centerTile(atPoint: position)
            
            let nodesInCenter = tileMap.nodes(at: center)
                //se o node estiver fora do tabuleiro 6x6 (0 ate 5)
                if column < 0 || column > 5 || row < 0 || row > 5 {
                    for piece in pieces where piece.node == node {
                        node.position = CGPoint(x: piece.xOrigin, y: piece.yOrigin)
                        self.newPos = PositionPiece(row: piece.xOrigin, column: piece.yOrigin)
                    }
                } else {
                    // se existir mais que um node na posição, volta para a posição anterior
                    if nodesInCenter.count > 1 && nodesInCenter.contains(node) {
                        node.position = CGPoint(x: previousPos!.row, y: previousPos!.column)
                        self.newPos = PositionPiece(row: previousPos!.row, column: previousPos!.column)
                    } else if nodesInCenter.count >= 1 && !nodesInCenter.contains(node) {
                        node.position = CGPoint(x: previousPos!.row, y: previousPos!.column)
                        self.newPos = PositionPiece(row: previousPos!.row, column: previousPos!.column)
                    
                    } else {
                        node.position = center
                        self.newPos = PositionPiece(row: center.x, column: center.y)
                    }
                }
            movesPices.append(Move(from: self.previousPos!, to: self.newPos!)) 
        }
        //Finaliza a movimentação do drag and drop
        self.currentNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
    
    
}


extension GameScene {
    func animateNodes(_ node: SKNode, pos: PositionPiece) {
        //for (index, node) in nodes.enumerated() {
            node.run(.sequence([
                .wait(forDuration: 0.01),
                .sequence([
                    .scale(to: 1.5, duration: 0.3),
                    .move(to: CGPoint(x: pos.row, y: pos.column), duration: 0.2),
                    .scale(to: 1, duration: 0.3),
                    .wait(forDuration: 2)
                ])
            ]))
//        }
    }
}
