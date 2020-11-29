//
//  Post.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Represents a post, which can be an original post or a reply to another post.
 */
class Post {
    
    // MARK: - Variables
    
    var identifier: String
    var timestamp: String
    var owner: String
    var media: String
    var message: String
    var likes: Int
    var liked: Bool
    
    // MARK: - Initilization
    
    /**
     Create a new Post object.
     - Parameter identifier: post ID
     - Parameter timestamp: when the post was created
     - Parameter owner: the user who created the post
     - Parameter media: Spotify URI
     - Parameter message: text of the post
     - Parameter likes: how many users have liked the post
     - Parameter liked: whether the current user liked the post
     */
    init(identifier: String, timestamp: String, owner: String, media: String,
         message: String, likes: Int, liked: Bool) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.media = media
        self.message = message
        self.likes = likes
        self.liked = liked
    }
}
