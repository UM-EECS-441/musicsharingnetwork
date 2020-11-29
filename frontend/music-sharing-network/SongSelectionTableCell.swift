//
//  SongSelectionTableCell.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

/**
 Displays a song in the list of search results.
 */
class SongSelectionTableCell: UITableViewCell {
    
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
