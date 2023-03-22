//
//  SocketIOManager.swift
//  testeChat
//
//  Created by Admin on 20/02/23.
//

import Foundation

protocol ServiceDelegate: AnyObject {
    func didStart()
    func yourPlayer(_ team: Int)
    func newTurn(_ name: Int)
    func playerDidMove(_ name: String, from originIndex: PositionPiece , to newIndex: PositionPiece)
    func receivedMessage(_ name: Int, msg: String, data: String)
    func didWin()
    func didLose()
}
