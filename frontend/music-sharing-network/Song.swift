//
//  Song.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/26/20.
//

import UIKit

/**
 Represents a song.
 */
class Song {
    var spotifyURI: String!
    var spotifyLink: String?
    
    // User interface
    var image: UIImage?
    var artist: String?
    var album: String?
    var name: String?
    
    // Construct a song with only a URI
    init(uri: String) {
        self.spotifyURI = uri
    }
    
    // Construct a song with all its UI elements
    init(uri: String, link: String, image: UIImage, artist: String, album: String, name: String) {
        self.spotifyURI = uri
        self.spotifyLink = link
        
        self.image = image
        self.artist = artist
        self.album = album
        self.name = name
    }
}
