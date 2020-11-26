//
//  SpotifyWebAPI.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

class SpotifyWebAPI {
    private static let spotifyWebAPIBaseURL: String = "https://api.spotify.com/v1"
    private static let spotifyAccountsBaseURL: String = "https://accounts.spotify.com/api"
    
    private static let spotifyClientID: String = "c0a5c9b2c5b94d00b5599dd76b092414"
    private static let spotifyClientSecret: String = "225ff590d76d4d6db2168af29e627dd4"
    
    private static var token: String? = nil
    private static var expires: Date? = nil
    private static var authenticated: Bool {
        get {
            return self.token != nil && self.expires != nil && self.expires! > Date()
        }
    }
    
    private static var authLock: NSLock = NSLock()
    
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
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200) {
            (data: Data?, response: URLResponse?, error: Error?) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                let token = json["access_token"] as! String
                let expires = Date() + TimeInterval(json["expires_in"] as! Int)
                
                self.token = token
                self.expires = expires
                condition.signal()
                
                print("SpotifyWebAPI > authenticate: Successfully set token '\(self.token!)' to expire at '\(self.expires!)'")
            } catch let error as NSError {
                print("SpotifyWebAPI > authenticate - ERROR: \(error))")
            }
        }
        
        condition.wait()
    }
    
    /**
     Get information about a track from the Spotify search API.
     
     - Parameter uri: Spotify track URI of the format 'spotify:track:<track number>'
     - Parameter callback: function to execute after receiving a response from the Spotify API
     */
    static func getTrack(uri: String, callback: @escaping (String, UIImage, String, String) -> Void) {
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
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200) { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                var link: String = "https://open.spotify.com"
                var image: UIImage = UIImage(systemName: "photo")!
                var song: String = "Unknown Song"
                var artist: String = "Unknown Artist"
                
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                let external_urls = json["external_urls"] as! [String: Any]
                link = external_urls["spotify"] as! String
                
                song = json["name"] as! String
                
                let artists = json["artists"] as! [Any]
                if artists.count > 0 {
                    let artistItem = (artists[0] as! [String: Any])
                    artist = artistItem["name"] as! String
                }
                
                let album = json["album"] as! [String: Any]
                let images = album["images"] as! [Any]
                if images.count > 0 {
                    let imageItem = images[0] as! [String: Any]
                    let imageURL = imageItem["url"] as! String
                    if let imageURLObject = URL(string: imageURL) {
                        if let imageData = try? Data(contentsOf: imageURLObject) {
                            image = UIImage(data: imageData) ?? image
                        }
                    }
                }
                
                callback(link, image, song, artist)
            } catch let error as NSError {
                print("SpotifyWebAPI > getTrack - ERROR: \(error)")
            }
        }
    }
    
    static func search(query: String) -> [String] {
        var results: [String] = [String]()
        
        if self.token == nil || self.expires == nil || self.expires! < Date() {
            self.authenticate()
            if self.token == nil || self.expires == nil || self.expires! < Date() {
                return results
            }
        }
        
        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return results
        }
        
        // Build an HTTP request
        let requestURL = self.spotifyWebAPIBaseURL + "/search?type=track&q=\(q)"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SpotifyWebAPI > search: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("SpotifyWebAPI > search: ERROR - HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    guard let tracks = json["tracks"] as? [String: Any] else { return }
                    guard let items = tracks["items"] as? [Any] else { return }
                    
                    results = items.map { (item: Any) -> String in
                        guard let i = item as? [String: Any] else { return "" }
                        guard let uri = i["uri"] as? String else { return "" }
                        
                        return uri
                    }.filter { (item: String) -> Bool in
                        return item != ""
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        
        return results
    }
}
