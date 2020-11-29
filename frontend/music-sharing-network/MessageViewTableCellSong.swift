//
//  MessageViewTableCellSong.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Display a song in a conversation.
 */
class MessageViewTableCellSong: UITableViewCell {
    
    // MARK: - Variables
    
    // User who sent the message
    var owner: String?
    // Message ID
    var identifier: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var songView: SongView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Event Handlers
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
