//
//  Message.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class Message {
    var identifier: String
    var timestamp: String
    var owner: String
    var text: String

    init(identifier: String, timestamp: String, owner: String, text: String) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.text = text
    }
}
