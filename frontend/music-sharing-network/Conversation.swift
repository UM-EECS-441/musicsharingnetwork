//
//  Conversation.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class Conversation {
    var identifier: String
    var members: [String]
    
    init(identifier: String, members: [String]) {
        self.identifier = identifier
        self.members = members
    }
}
