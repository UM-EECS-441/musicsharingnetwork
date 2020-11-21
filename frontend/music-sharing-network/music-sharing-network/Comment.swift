//
//  Comment.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//

import UIKit

class Comment {
    var identifier: String
    var timestamp: String
    var owner: String
    var message: String
    
    init(identifier: String, timestamp: String, owner: String, message: String) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.message = message
    }
}
