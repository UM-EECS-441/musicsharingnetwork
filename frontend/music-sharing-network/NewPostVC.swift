//
//  PostVC.swift
//  music-sharing-network
//
//  Created by Andrew on 10/30/20.
//

import UIKit

class NewPostVC: UIViewController {
    
    var song: String?
    
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.songView.showSong(uri: self.song!, parentVC: self)
        self.songView.shareButton.isHidden = true
    }
    
    @IBAction func addPost(_ sender: Any) {
        // Send the song title and artist as the message text
        
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["message": self.captionTextView.text ?? "", "content": self.songView.spotifyURI!, "reply_to": 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/create/"
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
                print("NewPostVC > addPost: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("NewPostVC > addPost: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Mark the user as logged in by saving their username,
                // and dismiss the login screen
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
