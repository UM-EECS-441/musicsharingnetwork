//
//  MessageViewTableCellText.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/17/20.
//

import UIKit

class MessageViewTableCellText: UITableViewCell {
    
    var owner: String?
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
