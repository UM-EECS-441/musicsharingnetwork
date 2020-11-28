//
//  NewMessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/17/20.
//

import UIKit

class NewMessageVC: UIViewController {
    
    @IBOutlet weak var recipientInput: UITextField!
    @IBOutlet weak var messageInput: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Serialize the message into JSON data
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "text", "content": self.messageInput.text ?? ""] as [String: String])
        
        // Send a request to the backend API to send a message
        BackendAPI.sendMessage(recipients: [self.recipientInput.text ?? ""], message: String(data: messageText!, encoding: .utf8) ?? "", successCallback: { (message: Message) in
            // Dismiss the screen once the message has been sent
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
