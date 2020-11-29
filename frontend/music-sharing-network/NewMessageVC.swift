//
//  NewMessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/17/20.
//

import UIKit

/**
 Display a form for the user to send a message.
 */
class NewMessageVC: UIViewController {
    
    // MARK: - User Interface
    
    @IBOutlet weak var recipientInput: UITextField!
    @IBOutlet weak var messageInput: UITextView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - Event Handlers
    
    /**
     Dismiss the keyboard.
     */
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Cancel new message by dismissing the view.
     - Parameter sender: object that triggered this event
     */
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Send the message.
     - Parameter sender: object that triggered this event
     */
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Serialize the message into JSON data
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "text", "content": self.messageInput.text ?? ""] as [String: String])
        
        // Send a request to the backend API to send a message
        BackendAPI.sendMessage(recipients: [self.recipientInput.text ?? ""], message: String(data: messageText!, encoding: .utf8) ?? "", successCallback: { (message: Message) in
            // Dismiss the screen once the message has been sent
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                
                // Also notify the message displays that there's a new message
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageSent"), object: nil)
            }
        })
    }
    
}
