//
//  Post.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class Post {
    var identifier: String
    var timestamp: String
    var owner: String
    var media: String
    var message: String
    var likes: Int
    var reposts: Int
    
    init(identifier: String, timestamp: String, owner: String, media: String,
         message: String, likes: Int, reposts: Int) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.media = media
        self.message = message
        self.likes = likes
        self.reposts = reposts
    }
}
