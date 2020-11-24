//
//  SpotifyWebAPI.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

class SpotifyWebAPI {
    private static let spotifyWebAPIBaseURL = "https://api.spotify.com/v1"
    private static let spotifyAccountsBaseURL = "https://accounts.spotify.com/api"
    
    private static var expires: Date?
    private static var token: String?
    
    private static func authenticate() {
        print("SpotifyWebAPI > authenticate: Attempting authentication")
        
        guard let base64credentials: String = "\(SharedData.spotifyClientID):\(SharedData.spotifyClientSecret)".data(using: String.Encoding.utf8)?.base64EncodedString() else {
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
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SpotifyWebAPI > authenticate: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("SpotifyWebAPI > authenticate: ERROR - HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    self.token = json["access_token"] as? String
                    self.expires = Date() + TimeInterval(json["expires_in"] as! Int)
                    
                    print("SpotifyWebAPI > authenticate: Successfully set token '\(self.token!)' to expire at '\(self.expires!)'")
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    static func getTrack(uri: String) -> (image: UIImage, song: String, artist: String) {
        var image: UIImage = UIImage(systemName: "photo")!
        var song: String = "Unknown Song"
        var artist: String = "Unknown Artist"
        
        if self.token == nil || self.expires == nil || self.expires! < Date() {
            self.authenticate()
            if self.token == nil || self.expires == nil || self.expires! < Date() {
                return (image, song, artist)
            }
        }
        
        guard let id = uri.components(separatedBy: ":").last?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return (image, song, artist)
        }
        
        // Build an HTTP request
        let requestURL = self.spotifyWebAPIBaseURL + "/tracks/\(id)"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SpotifyWebAPI > getTrack: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("SpotifyWebAPI > getTrack: ERROR - HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    if let artists = json["artists"] as? [Any] {
                        if artists.count > 0 {
                            if let a0 = artists[0] as? [String:Any] {
                                if let artistName = a0["name"] as? String {
                                    artist = artistName
                                }
                            }
                        }
                    }
                    
                    if let songName = json["name"] as? String {
                        song = songName
                    }
                    
                    if let album = json["album"] as? [String: Any] {
                        if let images = album["images"] as? [Any] {
                            if images.count > 0 {
                                if let i0 = images[0] as? [String: Any] {
                                    if let i0URL = i0["url"] as? String {
                                        if let imageURL = URL(string: i0URL) {
                                            if let imageData = try? Data(contentsOf: imageURL) {
                                                image = UIImage(data: imageData) ?? image
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        
        return (image, song, artist)
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
