//
//  MessageListTableCell.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Display a conversation preview.
 */
class MessageListTableCell: UITableViewCell {
    
    // MARK: - Variables
    
    // Conversation ID
    var identifier: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
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
