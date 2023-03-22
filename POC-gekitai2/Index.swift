//
//  Index.swift
//  POC-gekitai2
//
//  Created by Admin on 24/02/23.
//

import Foundation

struct Index: Codable, Equatable {
    let row: Int
    let column: Int
}

struct PositionPiece: Codable, Equatable {
    let row: Double
    let column: Double
}

struct Move: Codable {
    var from: PositionPiece
    var to: PositionPiece
}

struct Mensagem: Codable {
    var sender: String
    var content: String
    var data: String?
}

enum Player: String {
    case disconnected = ""
    case playerTop = "playerTop"
    case playerBottom = "playerBottom"
}

enum GameState: String {
    case awaiting = "Aguardando jogador..."
    case waiting = "Oponente jogando..."
    case yourTurn = "Agora é sua vez!"
}
