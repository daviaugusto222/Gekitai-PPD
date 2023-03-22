//
//  RoomViewController.swift
//  POC-gekitai2
//
//  Created by user on 21/03/23.
//

import UIKit

class RoomViewController: UIViewController {
    
    @IBOutlet weak var codeRoomLabel: UILabel!
    @IBOutlet weak var nomeTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        RPCManager.shared.run { (port) in
            DispatchQueue.main.async {
                self.codeRoomLabel.text = String(port)
            }
        }
        
        RPCManager.shared.onStart {
            UserDefaults.standard.set(1, forKey: "number")
            self.start()
        }
    }
    

    @IBAction func invite(_ sender: UIButton) {
        
        let name = codeTextField.text!
        
        guard let port = Int(codeTextField.text!) else { return }
        
        RPCManager.shared.client.port = port
        
        RPCManager.shared.client.invite(name: name) { (success) in
            if success {
                UserDefaults.standard.set(name, forKey: "name")
                nomeTextField.isEnabled = false
                codeTextField.isEnabled = false
                sender.backgroundColor = .systemGreen
                sender.setTitle("CONECTADO", for: .normal)
            }
        }
    }
    
    
    @IBAction func start(_ sender: Any) {
        RPCManager.shared.client.start { (success) in
            if success {
                UserDefaults.standard.set(0, forKey: "number")
                self.start()
            }
        }
    }
    
    
    private func start() {
        DispatchQueue.main.async {
            self.startButton.isEnabled = false
            self.startButton.alpha = 0.5
            
            //NotificationCenter.default.post(name: .start, object: nil)
            
            let chat = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "game-kaeru") as! GameViewController
            
            chat.view.frame = self.view.bounds
            self.view.addSubview(chat.view)
            
            UIView.transition(from: self.view, to: chat.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
                chat.didMove(toParent: self)
                
            }
            
        }
        
    }

}
