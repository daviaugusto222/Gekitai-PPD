//
//  GameViewController.swift
//  POC-gekitai2
//
//  Created by Admin on 14/02/23.
//

import UIKit
import SpriteKit
import GameplayKit

class TableCell: UITableViewCell {
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var mensagem: UITextView!
}

struct mensagem {
    var nome: String
    var msg: String
    var data: String
}

enum Player: String {
    case disconnected = ""
    case playerTop = "top"
    case playerBottom = "bottom"
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textfield: UITextField!
    
    let service: Service = Service()
    var textos = [mensagem]() {
        didSet {
            table.reloadData()
        }
    }
    var player: Player = .disconnected
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        service.delegate = self
        
        //if let view = self.view as! SKView? {
        // Load the SKScene from 'GameScene.sks'
        
        if let scene = GKScene(fileNamed: "GameScene"), let scene = scene.rootNode as! GameScene? {
            //if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            skview.presentScene(scene)
        }
        
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //askNickname()
        self.service.conectaPlayer(player: player.rawValue)
    }
    
    @IBAction func enviaMensagem(_ sender: Any) {
        service.enviaMensagem(player: player.rawValue, mensagem: textfield.text ?? "nada")
        self.textfield.text?.removeAll()
    }
    
    func askNickname() {
        let alertController = UIAlertController(title: "GEKITAI", message: "Entre com seu nome", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "Entrar", style: UIAlertAction.Style.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.count == 0 {
                self.askNickname()
            }
            else {
                //self.player = textfield.text
                self.service.conectaPlayer(player: textfield.text ?? "bundao")
                
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        textos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse or create a cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        // For a standard cell, use the UITableViewCell properties.
        cell.nome.text = textos[indexPath.row].nome
        cell.mensagem.text = textos[indexPath.row].msg
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, HH:mm"
        //cell.data.text = dateFormatterPrint.string(from: textos[indexPath.row].data)
        cell.data.text = textos[indexPath.row].data
        return cell
    }
}

extension GameViewController: ServiceDelegate {
    func didStart() {
        print("Conectado")
        

        
    }
    
    func yourPlayer(_ team: String) {
        self.player = Player(rawValue: team) ?? .disconnected
    }
    
    func newTurn(_ name: String) {
        print("seu turno")
    }
    
    func playerDidMove(_ name: String, from originIndex: Int, to newIndex: Int) {
        print("1")
    }
    
    func receivedMessage(_ name: String, msg: String, data: String) {
        textos.append(mensagem(nome: name, msg: msg, data: data))
    }
    
    
}
