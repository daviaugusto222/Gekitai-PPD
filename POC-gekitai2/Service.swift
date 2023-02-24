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
    func playerDidMove(_ name: String, from originIndex: Int , to newIndex: Int)
    
    func receivedMessage(_ name: String, msg: String, data: String)
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
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress, .forceWebsockets(true)])
        socket = manager.defaultSocket
        configuraSocket()
    }
    
    private func start() {
        socket.connect()
    }
    
    func conectaPlayer(player: String) {
        self.socket.emit("ctUser", player)
    }
    
    func exitPlayer(player: String) {
        self.socket.emit("exitUser", player)
    }
    
    func enviaMensagem(player: String, mensagem: String) {
        self.socket.emit("chatMessage", player, mensagem)
    }
    
    func configuraSocket() {
        
        socket.on("player") { [weak self] data, ack -> Void in
            if let name = data[0] as? String {
                self?.player = name
                self?.delegate?.yourPlayer(name)
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            self?.player = ""
            self?.delegate?.yourPlayer("")
        }
        
        socket.on("uList") { [weak self] data, ack -> Void in
            if let name = data[0] as? String {
                self?.delegate.didStart()
                self?.delegate.receivedMessage("🟢", msg: "Usuário: \(name)", data: "")
            }
        }
        
        socket.on("newChatMessage") { [weak self] data, ack -> Void in
            if let name = data[0] as? String, let msg = data[1] as? String, let data = data[2] as? String {
                self?.delegate.receivedMessage(name, msg: msg, data: data)
            }
        }
        
        socket.on("startGame") { [weak self] data, ack in
            self?.delegate.didStart()
            return
        }
        
        
    }
    
}
    
    
