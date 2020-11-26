//
//  MessageListTableCell.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class MessageListTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
