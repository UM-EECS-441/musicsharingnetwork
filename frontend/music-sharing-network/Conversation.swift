//
//  Conversation.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Represents a conversation between users.
 */
class Conversation {
    
    // MARK: - Variables
    
    // Conversation ID
    var identifier: String
    // List of users in the conversation
    var members: [String]
    
    // MARK: - Initialization
    
    /**
     Construct a new Conversation object.
     - Parameter identifier: conversation ID
     - Parameter members: list of users in the conversation
     */
    init(identifier: String, members: [String]) {
        self.identifier = identifier
        self.members = members
    }
    
}
