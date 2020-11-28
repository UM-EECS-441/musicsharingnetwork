//
//  TimelineTableCell.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class TimelineTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var textBox: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var likeButtonAction : (() -> Void)?
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.likeButton.addTarget(self, action: #selector(self.likeTapped(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        self.likeButton.isHidden = !SharedData.logged_in
    }
    
    @objc func loginChanged() {
        self.likeButton.isHidden = !SharedData.logged_in
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        // Send a request to the backend API to like or unlike the post
        BackendAPI.likePost(identifier: self.identifier!, successCallback: { (liked: Bool) in
            // Update the UI
            DispatchQueue.main.async {
                self.isLiked = liked
                self.likeButtonAction?()
            }
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
