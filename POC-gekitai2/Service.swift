//
//  SocketIOManager.swift
//  testeChat
//
//  Created by Admin on 20/02/23.
//

import Foundation
import SocketIO

protocol ServiceDelegate: AnyObject {
    func didStart()
    func yourPlayer(_ team: String)
    func newTurn(_ name: String)
    func playerDidMove(_ name: String, from originIndex: PositionPiece , to newIndex: PositionPiece)
    func receivedMessage(_ name: String, msg: String, data: String)
    func didWin()
    func didLose()
}

class Service {
    let manager: SocketManager
    let socket: SocketIOClient
    
    weak var delegate: ServiceDelegate! {
        didSet {
            self.start()
        }
    }
    
    var player: String!
    
    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        configuraSocket()
    }
    
    private func start() {
        socket.connect()
    }
    
    func restart() {
        socket.disconnect()
        socket.connect()
    }
    
    func surreder() {
        self.socket.emit("surrender", player)
    }
    
    func conectaPlayer() {
        self.socket.emit("ctUser")
    }
    
    func newTurn() {
        self.socket.emit("newTurn", player)
    }
    
    func enviaMensagem(nome: String, mensagem: String) {
        self.socket.emit("chatMessage", nome, mensagem)
    }
    
    func move(from originPos: PositionPiece, to newPos: PositionPiece) {
        self.socket.emit("playerMove", player, originPos.x, originPos.y, newPos.x, newPos.y)
    }
    
    func configuraSocket() {
        socket.on("player") { [weak self] data, ack in
            if let name = data[0] as? String {
                if self?.player == nil {
                    self?.player = name
                    self?.delegate.yourPlayer(name)
                }
                self?.delegate.receivedMessage("🟢", msg: "\(name) entrou", data: "")
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            self?.player = nil
            self?.delegate.yourPlayer("")
        }
        
        socket.on("uList") { [weak self] data, ack in
            if let name = data[0] as? String {
                self?.delegate.receivedMessage("🟢", msg: "Usuário \(name) se conectou", data: "")
            }
        }
        
        socket.on("newChatMessage") { [weak self] data, ack in
            if let name = data[0] as? String, let msg = data[1] as? String, let data = data[2] as? String {
                self?.delegate.receivedMessage(name, msg: msg, data: data)
            }
        }
        
        socket.on("playerMove") { [weak self] data, ack in
            if let name = data[0] as? String, let originX = data[1] as? Double, let originY = data[2] as? Double, let newX = data[3] as? Double, let newY = data[4] as? Double {
                self?.delegate.playerDidMove(name, from: PositionPiece(x: originX, y: originY), to: PositionPiece(x: newX, y: newY))
            }
        }
        
        socket.on("startGame") { [weak self] data, ack in
            self?.delegate.didStart()
            self?.delegate.receivedMessage("🔹", msg: "Game Start!", data: "")
        }
        
        socket.on("currentTurn") { [weak self] data, ack in
            if let name = data[0] as? String {
                self?.delegate.newTurn(name)
            }
        }
        
        socket.on("win") { [weak self] data, ack in
            self?.delegate.didWin()
        }
        
        socket.on("lose") { [weak self] data, ack in
            self?.delegate.didLose()
        }
        
        
        socket.onAny {
            print("Got event: \($0.event), with items: \($0.items!)")
        }
        
    }
    
}


