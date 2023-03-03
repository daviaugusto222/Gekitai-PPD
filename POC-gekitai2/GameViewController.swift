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
    case awaiting = "Aguardando jogador..."
    case waiting = "Oponente jogando..."
    case yourTurn = "Agora é sua vez!"
}

class GameViewController: UIViewController {
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var finalizarTurnoButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    let service: Service = Service()
    var textos = [Mensagem]() {
        didSet {
            table.reloadData()
            if !textos.isEmpty {
                table.layoutIfNeeded()
                table.scrollToRow(at: IndexPath(row: textos.count - 1, section: 0), at: .bottom, animated: true)
            }
            
        }
    }
    
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
        service.delegate = self
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         
    }
    
    @IBAction func enviaMensagem(_ sender: Any) {
        guard let mensagem = textfield.text else { return }
        if mensagem != "" {
            service.enviaMensagem(nome: player.rawValue, mensagem: mensagem)
            self.textfield.text?.removeAll()
        }
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
        if textos[indexPath.row].nome == "playerBottom" {
            cell.nome.text = "🟣 Roxos"
        } else if textos[indexPath.row].nome == "playerTop" {
            cell.nome.text = "🔴 Vermelhos"
        } else {
            cell.nome.text = textos[indexPath.row].nome
        }
        cell.mensagem.text = textos[indexPath.row].msg
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
        gameScene.movePiece(originPos: originIndex, newPos: newIndex)
    }
    
    func receivedMessage(_ name: String, msg: String, data: String) {
        textos.append(Mensagem(nome: name, msg: msg, data: data))
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
