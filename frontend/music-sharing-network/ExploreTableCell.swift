//
//  ExploreTableCell.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/3/20.
//

import UIKit

class ExploreTableCell: UITableViewCell {
    
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
