//
//  ShareSongVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Display a form for the user to share a song.
 */
class ShareSongVC: UIViewController {
    
    // MARK: - Variables
    
    // Spotify URI of song to share
    // (must be populated before the view is displayed)
    var song: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var recipientInput: UITextField!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Show the song to be shared
        self.songView.showSong(uri: self.song!, parentVC: self)
        self.songView.shareButton.isHidden = true
    }
    
    // MARK: - Event Handlers
    
    /**
     Dismiss the keyboard.
     */
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Cancel song share by dismissing the view.
      - Parameter sender: object that triggered this event
     */
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Send a message to share the song.
     - Parameter sender: object that triggered this event
     */
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
