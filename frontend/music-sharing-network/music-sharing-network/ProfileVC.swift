//
//  UserVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/29/20.
//

import UIKit

/*
 Controls a view that shows a user's profile. Can show the logged in user's
 profile or another user's profile.
 */
class ProfileVC: UIViewController {
    // Is the user viewing their own profile?
    var myProfile: Bool = true
    // If not, whose profile are they viewing?
    var username: String = ""
    var isFollowed: Bool = false
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var bioBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        // If the user is viewing their own profile, hide the follow button and
        // make sure they're logged in. If the user is viewing someone else's
        // profile, hide the settings button and set the navBar title to be the
        // username of whoever we're viewing.
        if myProfile {
            self.followButton.isHidden = true
            
            if SharedData.logged_in {
                self.navBar.rightBarButtonItem?.title = "Settings"
                self.navBar.rightBarButtonItem?.isEnabled = true
                
                self.username = SharedData.username
                self.getProfile()
            } else {
                SharedData.login(parentVC: self, completion: nil)
            }
        } else {
            self.navBar.rightBarButtonItem?.title = nil
            self.navBar.rightBarButtonItem?.isEnabled = false
            self.navBar.title = self.username
            
            if SharedData.logged_in {
                self.followButton.isHidden = self.username == SharedData.username
            } else {
                self.followButton.isHidden = true
            }
            
            self.getProfile()
        }
    }
    
    @objc func loginChanged() {
        if self.myProfile {
            if SharedData.logged_in {
                // User logged in on My Profile
                print("ProfileVC > loginChanged: User logged in on My Profile")
                self.username = SharedData.username
                self.getProfile()
                
                self.navBar.rightBarButtonItem?.title = "Settings"
                self.navBar.rightBarButtonItem?.isEnabled = true
            } else {
                // User logged out on My Profile
                print("ProfileVC > loginChanged: User logged in on My Profile")
                self.username = ""
                
                self.navBar.rightBarButtonItem?.title = nil
                self.navBar.rightBarButtonItem?.isEnabled = false
            }
        } else {
            if SharedData.logged_in {
                // User logged in on another profile
                print("ProfileVC > loginChanged: User logged in on another profile")
                self.followButton.isHidden = self.username == SharedData.username
            } else {
                // User logged out on another profile
                print("ProfileVC > loginChanged: User logged out on another profile")
                self.followButton.isHidden = false
            }
        }
    }
    
    /*
     Retrieve a user's profile information from the backend, and update the view
     accordingly.
     */
    func getProfile() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/\(self.username)/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("ProfileVC > getProfile: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("ProfileVC > getProfile: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Update the view with the data from the backend
                if let json = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                    self.fullNameLabel.text = json["full_name"] as? String
                    self.usernameLabel.text = self.username
                    self.bioBox.text = json["user_bio"] as? String
                    self.isFollowed = false /* json["following"] */
                    if self.isFollowed {
                        self.followButton.setTitle("Unfollow", for: [])
                    } else {
                        self.followButton.setTitle("Follow", for: [])
                    }
                }
            }
        }
    }
    
    @IBAction func followTapped(_ sender: Any) {
        
        self.isFollowed.toggle()
        
        if isFollowed {
            
            // API request to follow user
            
            // Build an HTTP request
            let requestURL = SharedData.baseURL + "/users/" + self.username + "/follow/"
            var request = URLRequest(url: URL(string: requestURL)!)
            request.httpShouldHandleCookies = true
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Send the request and read the server's response
            SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
                // Check for errors
                guard let _ = data, error == nil else {
                    print("TimelineTableCellVC > followTapped: NETWORKING ERROR")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    // Check for errors
                    if httpResponse.statusCode != 201 {
                        print("TimelineTableCellVC > followTapped: HTTP STATUS: \(httpResponse.statusCode)")
                        return
                    }
                }
            }
            
            followButton.setTitle("Unfollow", for: [])
            
        } else {
            
            // API request to unfollow user
            
            // Build an HTTP request
            let requestURL = SharedData.baseURL + "/users/" + self.username + "/unfollow/"
            var request = URLRequest(url: URL(string: requestURL)!)
            request.httpShouldHandleCookies = true
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Send the request and read the server's response
            SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
                // Check for errors
                guard let _ = data, error == nil else {
                    print("TimelineTableCellVC > followTapped: NETWORKING ERROR")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    // Check for errors
                    if httpResponse.statusCode != 201 {
                        print("TimelineTableCellVC > followTapped: HTTP STATUS: \(httpResponse.statusCode)")
                        return
                    }
                    
                }
            }
            
            followButton.setTitle("Follow", for: [])
            
        }
    }
    
}
