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



class GameViewController: UIViewController {
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var finalizarTurnoButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    //let service: Service = Service()
    var textos = [Mensagem]() {
        didSet {
            DispatchQueue.main.async {
                self.table.reloadData()
                if !self.textos.isEmpty {
                    self.table.scrollToRow(at: IndexPath(row: self.textos.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    
    let user = UserDefaults.standard.integer(forKey: "number")
    var player: Player = .disconnected
        
    var gameScene: GameScene {
        return skview.scene as! GameScene
    }
    
    lazy var stateView: UIView = {
        let view = UIView(frame: self.skview.frame)
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        return view
    }()
    
    var state: GameState! = .awaiting {
        didSet {
            DispatchQueue.main.async {
                self.stateLabel.text = self.state.rawValue
                switch self.state {
                case .yourTurn:
                    self.dismissStateView()
                    self.finalizarTurnoButton.isEnabled = true
                default:
                    self.showStateView()
                    self.finalizarTurnoButton.isEnabled = false
                }
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == 0 {
            player = .playerBottom
        } else if user == 1 {
            player = .playerTop
        }
        
        table.dataSource = self
        table.delegate = self
        //service.delegate = self
        textfield.delegate = self
        
        if let scene = GKScene(fileNamed: "GameScene"), let scene = scene.rootNode as! GameScene? {
            scene.scaleMode = .aspectFill
            skview.presentScene(scene)
        }
        
        skview.ignoresSiblingOrder = true
        skview.showsFPS = false
        skview.showsNodeCount = false
        
        self.table.layer.cornerRadius = 10.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStateView()
        
        RPCManager.shared.onMessage { (message) in
            self.textos.append(message)
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
        RPCManager.shared.onMove {
            self.gameScene.movePiece(originPos: $0.from, newPos: $0.to)
            self.state = .yourTurn
            
        }
        
        RPCManager.shared.onRestart {
            DispatchQueue.main.async {
                let join = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "roomIdentify")
                join.view.frame = self.view.bounds
                self.view.addSubview(join.view)
                UIView.transition(from: self.view, to: join.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
                    join.didMove(toParent: self)
                }
            }
        }
        
    }
    
    
    @IBAction func enviaMensagem(_ sender: Any) {
        guard let mensagem = textfield.text else { return }
        if mensagem != "" {
            let message = Mensagem(sender: player.rawValue, content: mensagem)
            RPCManager.shared.client.send(message) { _ in
                self.textos.append(message)
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
            //service.enviaMensagem(nome: player.rawValue, mensagem: mensagem)
            //rpcManager.client.(nome: player.rawValue, mensagem: mensagem)
            self.textfield.text?.removeAll()
        }
    }
    
    @IBAction func finalizarTurno(_ sender: Any) {
        for move in gameScene.movesPices {
            //self.service.move(from: move.previousPos, to: move.newPos)
            //self.grpcClient.move(from: move.previousPos, to: move.newPos)
            RPCManager.shared.client.send(move) { _ in
            }
        }
        //self.service.newTurn()
        self.gameScene.newPos = nil
        self.gameScene.previousPos = nil
        self.gameScene.movesPices = []
        state = .waiting
        
    }
    

    
    @IBAction func desistir(_ sender: Any) {
        let alert = UIAlertController(title: "Desistir", message: "Você realmente deseja desistir?", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Desistir", style: .destructive, handler: { _ in self.restart() })
        alert.addAction(exit)
        alert.addAction(.init(title: "Voltar", style: .cancel, handler: .none))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Restart
    func restart() {
        //service.restart()
        //grpcClient.restart()
        RPCManager.shared.client.restart{ _ in }
        DispatchQueue.main.async {
            let join = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "roomIdentify")
            join.view.frame = self.view.bounds
            self.view.addSubview(join.view)
            UIView.transition(from: self.view, to: join.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
                join.didMove(toParent: self)
            }
        }
    }
    
    func showStateView() {
        DispatchQueue.main.async {
            self.view.addSubview(self.stateView)
        }
    }
    
    func dismissStateView() {
        DispatchQueue.main.async {
            self.stateView.removeFromSuperview()
        }
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
        if textos[indexPath.row].sender == "playerBottom" {
            cell.nome.text = "🟣 Roxos"
        } else {
            cell.nome.text = "🔴 Vermelhos"
        }
        cell.mensagem.text = textos[indexPath.row].content
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
        let alert = UIAlertController(title: "Você Ganhou! 🎉", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Jogar novamente", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLose() {
        textos.removeAll()
        let alert = UIAlertController(title: "Você Perdeu! 😭", message: "", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Jogar novamente", style: .default, handler: { _ in self.restart() })
        alert.addAction(exit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func yourPlayer(_ team: String) {
        //player = Player(rawValue: team) ?? .disconnected
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
        gameScene.movePiece(originPos: originIndex, newPos: newIndex)
    }
    
    func receivedMessage(_ name: String, msg: String, data: String) {
        //textos.append(Mensagem(sender: name, content: msg, data: data))
    }
}

extension GameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
           let currentText = textField.text ?? ""

           // attempt to read the range they are trying to change, or exit if we can't
           guard let stringRange = Range(range, in: currentText) else { return false }

           // add their new text to the existing text
           let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

           // make sure the result is under 16 characters
           return updatedText.count <= 20
    }
}
