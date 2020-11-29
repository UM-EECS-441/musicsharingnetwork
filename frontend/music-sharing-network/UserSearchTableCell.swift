//
//  UserSearchTableCell.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/19/20.
//

import UIKit

/**
 Display a username in a list of search results.
 */
class UserSearchTableCell: UITableViewCell {
    
    // MARK: - User Interface
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
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
