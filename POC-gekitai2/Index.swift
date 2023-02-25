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
    let x: Double
    let y: Double
}

struct Move {
    var previousPos: PositionPiece
    var newPos: PositionPiece
}
