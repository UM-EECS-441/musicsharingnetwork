//
//  ExploreTableCell.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/3/20.
//

import UIKit

/**
 Display a song in the list of recommendations.
 */
class ExploreTableCell: UITableViewCell {
    
    // MARK: - User Interface
    
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
