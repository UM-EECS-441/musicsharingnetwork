//
//  PostVC.swift
//  music-sharing-network
//
//  Created by Andrew on 10/30/20.
//

import UIKit

class NewPostVC: UIViewController {
    
    // MARK: - Variables
    
    // Spotify URI of the song accompanying this post
    // (must be populated before displaying this view)
    var song: String!
    
    // MARK: - User Interface
    
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var captionTextView: UITextView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Show the song that goes with this post
        self.songView.showSong(uri: self.song, parentVC: self)
        
        // Disable share button
        self.songView.shareButton.isHidden = true
    }
    
    // MARK: - Event Handlers
    
    /**
     Dismiss the keyboard.
     */
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Submit the new post.
     - Parameter sender: object that triggered this event
     */
    @IBAction func addPost(_ sender: Any) {
        // Send a request to the create post API
        BackendAPI.createPost(content: self.songView.spotifyURI, message: self.captionTextView.text ?? "", successCallback: { (post: Post) in
            // If it succeeds, dismiss the view
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
