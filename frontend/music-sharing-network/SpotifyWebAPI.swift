//
//  SpotifyWebAPI.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

/**
 Interface for accessing the Spotify Web API.
 */
class SpotifyWebAPI {
    // Authentication API
    private static let spotifyWebAPIBaseURL: String = "https://api.spotify.com/v1"
    // Web API
    private static let spotifyAccountsBaseURL: String = "https://accounts.spotify.com/api"
    
    // Developer credentials
    private static let spotifyClientID: String = "c0a5c9b2c5b94d00b5599dd76b092414"
    private static let spotifyClientSecret: String = "225ff590d76d4d6db2168af29e627dd4"
    
    // Authentication data
    private static var token: String? = nil
    private static var expires: Date? = nil
    private static var authenticated: Bool {
        get {
            return self.token != nil && self.expires != nil && self.expires! > Date()
        }
    }
    
    // Don't allow simultaneous authentication requests
    private static var authLock: NSLock = NSLock()
    
    /**
     Attempt to gain access to Spotify APIs by logging in with the client credentials authorization flow.
     */
    private static func authenticate() {
        print("SpotifyWebAPI > authenticate: Attempting authentication")
        
        // Encode credentials
        guard let base64credentials = ("\(self.spotifyClientID):\(self.spotifyClientSecret)".data(using: String.Encoding.utf8)?.base64EncodedString()) else {
            print("SpotifyWebAPI > authenticate - ERROR: Failed to encode credentials")
            self.authLock.unlock()
            return
        }
        
        // Build an HTTP request
        let requestURL = self.spotifyAccountsBaseURL + "/token?grant_type=client_credentials"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64credentials)", forHTTPHeaderField: "Authorization")
        
        // Synchronize authentication with HTTP request
        let condition: NSCondition = NSCondition()
        
        // Send the request and read the server's response
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: {
            (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get the access token and expiration data
                let token = json["access_token"] as! String
                let expires = Date() + TimeInterval(json["expires_in"] as! Int)
                
                // Save the access token and expiration date
                self.token = token
                self.expires = expires
                condition.signal()
                
                print("SpotifyWebAPI > authenticate: Successfully set token '\(self.token!)' to expire at '\(self.expires!)'")
            } catch let error as NSError {
                print("SpotifyWebAPI > authenticate - ERROR: \(error))")
            }
        }, errorCallback: nil)
        
        condition.wait()
    }
    
    /**
     Parse a track object from JSON to get the fields we're interested in.
     
     - Parameter track: JSON object
     - Returns: Spotify link, song name, album name, artist name, album cover
     */
    private static func parseTrack(json: [String: Any]) -> (link: String?, song: String?, album: String?, artist: String?, image: UIImage?) {
        // Default values passed to the callback function
        var link: String?
        var song: String?
        var album: String?
        var artist: String?
        var image: UIImage?
        
        // Get the song's link
        let external_urls = json["external_urls"] as! [String: Any]
        link = external_urls["spotify"] as? String
        
        // Get the song's name
        song = json["name"] as? String
        
        // Get the song's artist
        let artists = json["artists"] as! [Any]
        if artists.count > 0 {
            let artistItem = (artists[0] as! [String: Any])
            artist = artistItem["name"] as? String
        }
        
        // Get the song's album name and image
        let albumJSON = json["album"] as! [String: Any]
        album = albumJSON["name"] as? String
        let images = albumJSON["images"] as! [Any]
        if images.count > 0 {
            let imageItem = images[0] as! [String: Any]
            let imageURL = imageItem["url"] as! String
            if let imageURLObject = URL(string: imageURL) {
                if let imageData = try? Data(contentsOf: imageURLObject) {
                    image = UIImage(data: imageData)
                }
            }
        }
        
        return (link, song, album, artist, image)
    }
    
    /**
     Get information about a track from the Spotify search API.
     
     - Parameter uri: Spotify track URI of the format 'spotify:track:<track number>'
     - Parameter callback: function to execute after receiving a response from the Spotify API
     */
    static func getTrack(uri: String, callback: @escaping (String, String?, String?, String?, String?, UIImage?) -> Void) {
        // Authenticate if necessary
        self.authLock.lock()
        if !self.authenticated {
            self.authenticate()
        }
        self.authLock.unlock()
        
        // Get the track ID
        guard let id = uri.components(separatedBy: ":").last?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            print("SpotifyWebAPI > getTrack - ERROR: Failed to get track ID")
            return
        }
        
        // Build an HTTP request
        let requestURL = self.spotifyWebAPIBaseURL + "/tracks/\(id)"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Parse the track data and execute the callback function
                let track = self.parseTrack(json: json)
                
                // Execute the callback function with the values retrieved from Spotify
                callback(uri, track.link, track.song, track.album, track.artist, track.image)
            } catch let error as NSError {
                print("SpotifyWebAPI > getTrack - ERROR: \(error)")
            }
        }, errorCallback: nil)
    }
    
    /**
     Search for songs using Spotify's search API.
     
     - Parameter query: search text
     - Parameter callback: function to execute upon receibing a response
     */
    static func search(query: String, callback: @escaping ([(uri: String, link: String?, song: String?, album: String?, artist: String?, image: UIImage?)]) -> Void) {
        // Authenticate if necessary
        self.authLock.lock()
        if !self.authenticated {
            self.authenticate()
        }
        self.authLock.unlock()
        
        // Encode the query for a URL
        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // Build an HTTP request
        let requestURL = self.spotifyWebAPIBaseURL + "/search?type=track&q=\(q)"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Get the list of tracks
                let tracks = json["tracks"] as! [String: Any]
                let items = tracks["items"] as! [Any]
                
                // Map the list to get the fields we need for each track
                let results = items.map { (item: Any) -> (String, String?, String?, String?, String?, UIImage?) in
                    let i = item as! [String: Any]
                    let uri = i["uri"] as! String
                    
                    let track = self.parseTrack(json: i)
                    
                    return (uri, track.link, track.song, track.album, track.artist, track.image)
                }
                
                // Execute the callback function with the results
                callback(results)
            } catch let error as NSError {
                print("SpotifyWebAPI > search - ERROR: \(error)")
            }
        }, errorCallback: nil)
    }
}
