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

struct Mensagem {
    var nome: String
    var msg: String
    var data: String
}

enum Player: String {
    case disconnected = ""
    case playerTop = "playerTop"
    case playerBottom = "playerBottom"
}

enum GameState: String {
    case awaitingConnection = "Awaiting Connection from another Player"
    case waiting = "Waiting for the Opponent's Move"
    case yourTurn = "Make your Move!"
    case youWin = "You Win!"
    case youLose = "You Lose!"
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textfield: UITextField!
    
    let service: Service = Service()
    var textos = [Mensagem]() {
        didSet {
            table.reloadData()
        }
    }
    
    var player: Player = .disconnected
    
    var gameScene: GameScene {
        return skview.scene as! GameScene
    }
    
    lazy var stateView: UIView = {
        let view = UIView(frame: self.skview.frame)
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        return view
    }()
    
    var state: GameState! = .awaitingConnection {
        didSet {
            switch state {
            case .yourTurn:
                dismissStateView()
            default:
                showStateView()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        service.delegate = self
        
        if let scene = GKScene(fileNamed: "GameScene"), let scene = scene.rootNode as! GameScene? {
            scene.scaleMode = .aspectFill

            skview.presentScene(scene)
        }
        
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStateView()
    }
    
    @IBAction func enviaMensagem(_ sender: Any) {
        service.enviaMensagem(nome: player.rawValue, mensagem: textfield.text ?? "nada")
        self.textfield.text?.removeAll()
    }
    
    @IBAction func finalizarTurno(_ sender: Any) {
        for move in gameScene.movesPices {
            self.service.move(from: move.previousPos, to: move.newPos)
        }
        self.service.newTurn()
    }
    
    @IBAction func desistir(_ sender: Any) {
        let alert = UIAlertController(title: "Desistir", message: "Você realmente deseja desistir?", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Desistir", style: .destructive, handler: { _ in self.service.surreder() })
        alert.addAction(exit)
        alert.addAction(.init(title: "Voltar", style: .cancel, handler: .none))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Restart
    func restart() {
        service.restart()
        viewDidLoad()
        viewDidAppear(true)
    }
    
    func showStateView() {
        self.view.addSubview(stateView)
    }
    
    func dismissStateView() {
        stateView.removeFromSuperview()
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
        if player == .playerBottom {
            state = .yourTurn
        } else {
            state = .waiting
        }
    }
    
    func didWin() {
        textos.removeAll()
        let alert = UIAlertController(title: "You Win", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Play Again", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLose() {
        textos.removeAll()
        let alert = UIAlertController(title: "You Lose", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Play Again", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func yourPlayer(_ team: String) {
        player = Player(rawValue: team) ?? .disconnected
    }
    
    func newTurn(_ name: String) {
        self.gameScene.newPos = nil
        self.gameScene.previousPos = nil
        self.gameScene.movesPices = []
        if name == player.rawValue {
            state = .waiting
        } else {
            state = .yourTurn
        }
    }
    
    func playerDidMove(_ name: String, from originIndex: PositionPiece, to newIndex: PositionPiece) {
        print("ALGO SE MOVEU \(originIndex) -> \(newIndex)")
        gameScene.movePiece(originPos: originIndex, newPos: newIndex)
    }
    
    func receivedMessage(_ name: String, msg: String, data: String) {
        textos.append(Mensagem(nome: name, msg: msg, data: data))
    }
}
