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
    
    var likeButtonAction : ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.likeButton.addTarget(self, action: #selector(self.likeTapped(_:)), for: .touchUpInside)
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        // Don't do anything if the user is not logged in
        if SharedData.logged_in {
            // Send a request to the backend API to like or unlike the post
            BackendAPI.likePost(identifier: self.identifier!, successCallback: { (liked: Bool) in
                // Update the UI
                DispatchQueue.main.async {
                    self.likeButtonAction?(liked)
                }
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
