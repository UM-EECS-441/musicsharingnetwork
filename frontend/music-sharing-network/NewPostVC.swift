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
        // Send a request to the create post API
        BackendAPI.createPost(content: self.songView.spotifyURI, message: self.captionTextView.text ?? "", successCallback: { (post: Post) in
            // If it succeeds, dismiss the view
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
