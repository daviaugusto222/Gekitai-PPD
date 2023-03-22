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
    
    var player: Player = .disconnected
    let user = UserDefaults.standard.integer(forKey: "number")
    
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
            self.stateLabel.text = state.rawValue
            switch state {
            case .yourTurn:
                dismissStateView()
                finalizarTurnoButton.isEnabled = true
            default:
                showStateView()
                finalizarTurnoButton.isEnabled = false
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    
    @IBAction func enviaMensagem(_ sender: Any) {
        guard let mensagem = textfield.text else { return }
        if mensagem != "" {
            let message = Mensagem(sender: player.hashValue, content: mensagem)
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
        }
        //self.service.newTurn()
        //self.grpcClient.newTurn()
        
    }
    
    @IBAction func desistir(_ sender: Any) {
        let alert = UIAlertController(title: "Desistir", message: "Você realmente deseja desistir?", preferredStyle: .alert)
        //let exit = UIAlertAction(title: "Desistir", style: .destructive, handler: { _ in self.grpcClient.surreder() })
        //alert.addAction(exit)
        alert.addAction(.init(title: "Voltar", style: .cancel, handler: .none))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Restart
    func restart() {
        //service.restart()
        //grpcClient.restart()
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
        if textos[indexPath.row].sender == user {
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
        gameScene.movePiece(originPos: originIndex, newPos: newIndex)
    }
    
    func receivedMessage(_ name: Int, msg: String, data: String) {
        
        textos.append(Mensagem(sender: name, content: msg, data: data))
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
