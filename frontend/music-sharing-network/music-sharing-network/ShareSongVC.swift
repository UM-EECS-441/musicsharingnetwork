//
//  ShareSongVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class ShareSongVC: UIViewController {
    var song: String?
    
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var recipientInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.songView.showSong(song: self.song!, parentVC: self)
        self.songView.shareButton.isHidden = true
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Send the song title and artist as the message text
        let messageContent = (self.songView.artistLabel.text ?? "Artist") + ":" + (self.songView.songLabel.text ?? "Song")
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "song", "content": messageContent] as [String: String])
        
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
