//
//  Server.swift
//  POC-gekitai2
//
//  Created by user on 21/03/23.
//

import Foundation
import GRPC
import NIO

class GekitaiServer {
    
    var port: Int?
    var isRunning = false
    var provider = GekitaiProvider()
    var onRun: ((Int) -> ())?
    
    func run() {
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        defer {
            try! group.syncShutdownGracefully()
        }
        
        let configuration = Server.Configuration(target: .hostAndPort("localhost", 0), eventLoopGroup: group, serviceProviders: [provider])
        
        let server = Server.start(configuration: configuration)
        
        server.map {
            $0.channel.localAddress
            }.whenSuccess { address in
            if let port = address?.port {
                self.port = port
                self.isRunning = true
                self.onRun?(port)
                print("server started on port \(port)")
            }
        }
        
        try? server.flatMap{ $0.onClose }.wait()
        
    }
    
}
