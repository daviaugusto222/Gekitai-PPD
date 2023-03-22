//
//  SocketIOManager.swift
//  testeChat
//
//  Created by Admin on 20/02/23.
//

import Foundation

protocol ServiceDelegate: AnyObject {
    func didStart()
    func yourPlayer(_ team: String)
    func newTurn(_ name: String)
    func playerDidMove(_ name: String, from originIndex: PositionPiece , to newIndex: PositionPiece)
    func receivedMessage(_ name: String, msg: String, data: String)
    func didWin()
    func didLose()
}
