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
        // Send the song title and artist as the message text
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "text", "content": self.messageInput.text ?? ""] as [String: String])
        
        // Serialize the recipient list and message into JSON data
        let json: [String: Any] = ["recipients": [self.recipientInput.text ?? ""], "message": String(data: messageText!, encoding: .utf8) as Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/send/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("ShareSongVC > sendButtonHandler: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("ShareSongVC > sendButtonHandler: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Dismiss the screen once the message has been sent
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
