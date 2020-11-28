//
//  BackendAPI.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/26/20.
//

import UIKit

/**
 Interface for making calls to our backend APIs.
 */
class BackendAPI {
    static let baseURL: String = "https://backend-qjgo4vxcdq-uc.a.run.app"
    
    // MARK: - Users
    
    /**
     Create a new user account.
     - Parameter username: username to claim
     - Parameter password: user's password
     - Parameter fullname: user's full name
     - Parameter bio: user's biography
     - Parameter successCallback: function to execute if account creation succeeds
     - Parameter errorCallback: function to execute if account creation fails
     */
    static func createAccount(username: String, password: String, fullname: String, bio: String, successCallback: ((String) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build a JSON object
        let json: [String: String] = ["username": username, "password": password, "full_name": fullname, "user_bio": bio]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > createAccount - ERROR: Failed to serialize JSON data")
            errorCallback?()
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/create/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 201, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?(username)
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Attempt to login with a username and password.
     - Parameter username: username to authenticate
     - Parameter password: password to the user's account
     - Parameter successCallback: function to execute if login succeeds
     - Parameter errorCallback: function to execute if login fails
     */
    static func login(username: String, password: String, successCallback: ((String) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > login - ERROR: Failed to serialize JSON data")
            errorCallback?()
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/login/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?(username)
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Log out of the current user's account.
     - Parameter successCallback: function to execute if login succeeds
     - Parameter errorCallback: function to execute if login fails
     */
    static func logout(successCallback: (() -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/logout/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?()
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Change the current user's password.
     - Parameter old: user's old password
     - Parameter new: user's new password
     - Parameter successCallback: function to execute if password change succeeds
     - Parameter errorCallback: function to execute if password change fails
     */
    static func changePassword(old: String, new: String, successCallback: (() -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["old_password": old, "new_password": new]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > changePassword - ERROR: Failed to serialize JSON data")
            errorCallback?()
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/password/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 204, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?()
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    // MARK: - Posts
    
    /**
     Parse a post from JSON data.
     - Parameter json: JSON object
     - Returns: post object, whether it represents a reply (false => post; true => reply)
     */
    static func parsePost(json: [String: Any]) -> (data: Post, isReply: Bool) {
        // Parse the post
        let post: Post = Post(
            identifier: json["post_id"] as! String,
            timestamp: json["timestamp"] as! String,
            owner: json["owner"] as! String,
            media: json["content"] as? String ?? "",
            message: json["message"] as? String ?? "",
            likes: json["num_likes"] as! Int,
            reposts: json["num_reposts"] as! Int
        )
        
        // Determine whether it's an original post or a reply
        if json["reply_to"] as? Int == 0 {
            return (post, false)
        } else {
            return (post, true)
        }
    }
    
    /**
     Get posts from people the current user follows.
     - Parameter successCallback: function to execute if post retrieval succeeds
     - Parameter errorCallback: function to execute if post retrieval fails
     */
    static func getPosts(successCallback: (([Post]) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get posts array
                let postList = json["posts"] as! [[String: Any]]
                
                // Convert it to an array of post objects
                var posts = [Post]()
                for postEntry in postList {
                    let post = self.parsePost(json: postEntry)
                    if !post.isReply {
                        posts.append(post.data)
                    }
                }
                
                successCallback?(posts)
            } catch let error as NSError {
                print("BackendAPI > getPosts - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Get a post and its replies.
     - Parameter identifier: post identifier
     - Parameter successCallback: function to execute if post retrieval succeeds
     - Parameter errorCallback: function to execute if post retrieval fails
     */
    static func getPostInfo(identifier: String, successCallback: ((Post, [Post]) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/\(identifier)/info/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get the post
                let postEntry = json["post"] as? [String: Any]
                let post = self.parsePost(json: postEntry!)
                
                // Get replies
                let repliesEntry = json["replies"] as! [[String: Any]]
                // Convert them an array of post objects
                var replies = [Post]()
                for replyEntry in repliesEntry {
                    let reply = self.parsePost(json: replyEntry)
                    if reply.isReply {
                        replies.append(reply.data)
                    }
                }
                // Reverse the order so we have the newest reply last
                replies.reverse()
                
                successCallback?(post.data, replies)
            } catch let error as NSError {
                print("BackendAPI > getInfo - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Create a new post.
     - Parameter content: Spotify URI
     - Parameter message: post text
     - Parameter replyTo: post ID to this replies to
     - Parameter successCallback: function to execute if post creation succeeds
     - Parameter errorCallback: function to execute if post creation fails
     */
    static func createPost(content: String, message: String, replyTo: String? = nil, successCallback: ((Post) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the post as JSON data
        let json: [String: Any] = ["message": message, "content": content, "reply_to": replyTo ?? 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/create/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 201, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Read the newly created post
                let post = parsePost(json: json["post"] as! [String: Any])
                
                successCallback?(post.data)
            } catch let error as NSError {
                print("BackendAPI > createPost - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
}
