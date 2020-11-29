//
//  MessageViewTableCellText.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/17/20.
//

import UIKit

/**
 Display a text message in a conversation.
 */
class MessageViewTableCellText: UITableViewCell {
    
    // MARK: - Variables
    
    // User who sent the message
    var owner: String?
    // Message ID
    var identifier: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
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
