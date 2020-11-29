//
//  CommentTableCell.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//

import UIKit

/**
 Display a comment.
 */
class CommentTableCell: UITableViewCell {
    
    // MARK: - Variables
    
    // Comment ID (comments are represented as posts in the databse)
    var identifier: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    
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
