//
//  NewMessageVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class NewMessageVC: UIViewController {
    var song: String?
    var artist: String?
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var recipientInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.artist = self.songArtistLabel.text
        self.song = self.songTitleLabel.text
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Send the song title and artist as the message text
        let message = self.artist! + ":" + self.song!
        
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["recipients": [self.recipientInput.text ?? ""], "message": message]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/send"
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
                print("NewMessageVC > sendButtonHandler: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("NewMessageVC > sendButtonHandler: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Mark the user as logged in by saving their username,
                // and dismiss the login screen
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
