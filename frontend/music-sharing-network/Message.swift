//
//  Message.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Represents a single message in a conversation.
 */
class Message {
    
    // MARK: - Variables
    
    // Message ID
    var identifier: String
    // When the message was sent
    var timestamp: String
    // User that sent the message
    var owner: String
    // Content of message
    var text: String

    // MARK: - Initialization
    
    /**
     Construct a new Message object.
     - Parameter identifier: message ID
     - Parameter timestamp: when the message was created
     - Parameter owner: user that sent the message
     - Parameter text: content of message
     */
    init(identifier: String, timestamp: String, owner: String, text: String) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.text = text
    }
    
}
