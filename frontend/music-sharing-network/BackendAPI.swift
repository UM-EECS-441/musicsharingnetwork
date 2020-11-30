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
    private static let baseURL: String = "https://backend-qjgo4vxcdq-uc.a.run.app"
    
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
        let requestURL = self.baseURL + "/users/create/"
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
        let requestURL = self.baseURL + "/users/login/"
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
        let requestURL = self.baseURL + "/users/logout/"
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
        let requestURL = self.baseURL + "/users/password/"
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
    
    /**
     Search users by username.
     - Parameter query: search query
     - Parameter successCallback: function to execute if search succeeds
     - Parameter errorCallback: function to execute if search fails
     */
    static func searchUsers(query: String, successCallback: (([String]) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the search query into JSON data
        let json: [String: Any] = ["prefix": query]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = self.baseURL + "/users/search"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Get the search results
                let results = json["usernames"] as! [String]
                
                successCallback?(results)
            } catch let error as NSError {
                print("BackendAPI > searchUsers - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Get a user's profile.
     - Parameter username: user to fetch
     - Parameter successCallback: function to execute if profile retrieval succeeds
     - Parameter errorCallback: function to execute if profile retrieval fails
     */
    static func getProfile(username: String, successCallback: ((String, String, String, Bool) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/users/\(username)/info/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Parse the user's profile info
                let username_ = json["target_user"] as! String
                let fullname = json["full_name"] as? String ?? ""
                let bio = json["user_bio"] as? String ?? ""
                let following = json["following"] as? Bool ?? false
                
                successCallback?(username_, fullname, bio, following)
            } catch let error as NSError {
                print("BackendAPI > getProfile - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Follow or unfollow a user.
     - Parameter username: user to follow/unfollow
     - Parameter successCallback: function to execute if follow/unfollow succeeds
     - Parameter errorCallback: function to execute if follow/unfollow fails
     */
    static func followUser(username: String, successCallback: ((Bool) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/users/" + username + "/follow/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Determine whether the user was followed or unfollowed
                let followed = json["followed"] as! Bool
                
                successCallback?(followed)
            } catch let error as NSError {
                print("BackendAPI > followUser - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    // MARK: - Posts
    
    /**
     Parse a post from JSON data.
     - Parameter json: JSON object
     - Returns: post object, whether it represents a reply (false => original post; true => reply)
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
            liked: json["liked"] as? Bool ?? false
        )
        
        // Determine whether it's an original post or a reply
        if json["reply_to"] as? String == nil {
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
        let requestURL = self.baseURL + "/posts/"
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
        let requestURL = self.baseURL + "/posts/\(identifier)/info/"
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
                print("BackendAPI > getPostInfo - ERROR: \(error)")
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
    static func createPost(content: String? = nil, message: String, replyTo: String? = nil, successCallback: ((Post) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the post as JSON data
        var json: [String: Any] = ["message": message]
        // Skip content field for comments
        if content != nil {
            json["content"] = content
        }
        // Skip reply_to field for original posts
        if replyTo != nil {
            json["reply_to"] = replyTo
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = self.baseURL + "/posts/create/"
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
    
    /**
     Like or unlike a post.
     - Parameter identifier: post identifier
     - Parameter successCallback: function to execute if like/unlike succeeds
     - Parameter errorCallback: function to execute if like/unlike fails
     */
    static func likePost(identifier: String, successCallback: ((Bool) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/posts/\(identifier)/like/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Determine whether the post was liked or unliked
                let liked = json["liked"] as! Bool
                
                successCallback?(liked)
            } catch let error as NSError {
                print("BackendAPI > likePost - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    // MARK: - Messages
    
    /**
     Get a list of all conversations the current user is a member of.
     - Parameter successCallback: function to execute if conversation retrieval succeeds
     - Parameter errorCallback: function to execute if conversation retrieval fails
     */
    static func getConversations(successCallback: (([Conversation]) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/messages/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get the list of the user's conversayions
                let conversationList = json["conversations"] as! [[String: Any]]
                // Convert it to conversation objects
                var conversations = [Conversation]()
                for convo in conversationList {
                    // Get the list of members in the conversation
                    var members = convo["members"] as! [String]
                    // Remove the current user from the members list unless
                    // it's a conversation with themself
                    if members.count > 1 {
                        members = members.filter({ (username: String) -> Bool in
                            return username != SharedData.username
                        })
                    }
                    
                    conversations.append(Conversation(identifier: convo["conversation_id"] as! String, members: members))
                }
                
                successCallback?(conversations)
            } catch let error as NSError {
                print("BackendAPI > getConversations - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Get messages that belong to a conversation.
     - Parameter identifier: conversation identifier
     - Parameter successCallback: function to execute if message retrieval succeeds
     - Parameter errorCallback: function to execute if message retrieval fails
     */
    static func getMessages(identifier: String, successCallback: (([Message]) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/messages/\(identifier)/info/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get the list of messages
                let jsonMessages = json["messages"] as! [[String: Any]]
                // Convert it to message objects
                var messages = [Message]()
                for message in jsonMessages {
                    messages.append(Message(identifier: message["id"] as! String, timestamp: message["timestamp"] as! String, owner: message["owner"] as! String, text: message["message"] as! String))
                }
                
                successCallback?(messages)
            } catch let error as NSError {
                print("BackendAPI > getMessages - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Send a new message.
     - Parameter recipients: list of users to send the message to
     - Parameter message: message text
     - Parameter successCallback: function to execute if message sends successfully
     - Parameter errorCallback: function to execute if message fails to send
     */
    static func sendMessage(recipients: [String], message: String, successCallback: ((Message) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the recipient list and message into JSON data
        let json: [String: Any] = ["recipients": recipients, "message": message]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = self.baseURL + "/messages/send/"
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
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // Get the newly created message
                let jsonMessage = json["message"] as! [String: Any]
                // Convert it to a message object
                let message: Message = Message(identifier: jsonMessage["id"] as! String, timestamp: jsonMessage["timestamp"] as! String, owner: jsonMessage["owner"] as! String, text: jsonMessage["message"] as! String)
                
                successCallback?(message)
            } catch let error as NSError {
                print("BackendAPI > sendMessage - ERROR: \(error)")
                errorCallback?()
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    // MARK: - Recommendations
    
    /**
     Get song recommendations.
     - Parameter successCallback: funciton to execute if recommendation retrieval succeeds
     - Parameter errorCallback: function to execute if recommendation retrieval fails
     */
    static func getRecommendations(successCallback: (([String]?, [String]?, [String]?) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = self.baseURL + "/recommendations/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                // Read the server's response as JSON data
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                // Get the list of recommended songs
                // FIXME: Replace these keys
                let artistRecommendations = json["TBD"] as? [String]
                let genreRecommendations = json["TBD"] as? [String]
                let attributeRecommendations = json["recommendations"] as? [String]
                
                successCallback?(artistRecommendations, genreRecommendations, attributeRecommendations)
            } catch let error as NSError {
                print("BackendAPI > getRecommendations - ERROR: \(error)")
            }
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
}
