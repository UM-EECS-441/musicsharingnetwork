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
        self.songView.showSong(uri: self.song!, parentVC: self)
        self.songView.shareButton.isHidden = true
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Serialize the song as a message in JSON data
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "song", "content": self.songView.spotifyURI] as [String: String])
        
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
