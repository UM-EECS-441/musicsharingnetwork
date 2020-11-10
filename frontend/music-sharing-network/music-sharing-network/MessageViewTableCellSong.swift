//
//  MessageViewTableCellSong.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class MessageViewTableCellSong: UITableViewCell {
    
    var owner: String?
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var songView: SongView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
