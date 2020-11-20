//
//  UserSearchTableCell.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/19/20.
//

import UIKit

class UserSearchTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
