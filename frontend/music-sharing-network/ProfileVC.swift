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
    
    // MARK: - Variables
    
    // Is the user viewing their own profile?
    var myProfile: Bool = true
    // If not, whose profile are they viewing?
    var username: String = ""
    // Do they follow the user?
    var isFollowed: Bool = false
    
    // MARK: - User Interface
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var bioBox: UILabel!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Respond when the user logs in or out
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        // If the user is viewing their own profile, hide the follow button and
        // make sure they're logged in. If the user is viewing someone else's
        // profile, hide the settings button and set the navBar title to be the
        // username of whoever they're viewing.
        if myProfile {
            self.followButton.isHidden = true
            
            if SharedData.logged_in {
                self.navBar.rightBarButtonItem?.title = "Settings"
                self.navBar.rightBarButtonItem?.isEnabled = true
                
                self.username = SharedData.username
                self.getProfile()
            } else {
                self.navBar.rightBarButtonItem?.title = nil
                self.navBar.rightBarButtonItem?.isEnabled = false
                
                SharedData.promptLogin(parentVC: self)
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
    
    // MARK: - Helpers
    
    /**
     Retrieve a user's profile information from the backend, and update the user interface
     accordingly.
     */
    private func getProfile() {
        // Send a request to the backend API to get the user's profile
        BackendAPI.getProfile(username: self.username, successCallback: { (username: String, fullname: String, bio: String, following: Bool) in
            // Update UI
            DispatchQueue.main.async {
                if !self.myProfile {
                    self.navBar.title = username
                }
                self.usernameLabel.text = username
                self.usernameLabel.sizeToFit()
                self.fullNameLabel.text = fullname
                self.fullNameLabel.sizeToFit()
                self.bioBox.text = bio
                self.bioBox.sizeToFit()
                self.isFollowed = following
                
                if self.isFollowed {
                    self.followButton.setTitle("Unfollow", for: [])
                } else {
                    self.followButton.setTitle("Follow", for: [])
                }
            }
        })
    }
    
    // MARK: - Event Handlers
    
    /**
     Hide or show the appropriate UI elemtents when the user logs in or out.
     */
    @objc private func loginChanged() {
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
                print("ProfileVC > loginChanged: User logged out on My Profile")
                self.username = ""
                
                self.navBar.rightBarButtonItem?.title = nil
                self.navBar.rightBarButtonItem?.isEnabled = false
                
                self.navigationController?.popToRootViewController(animated: true)
                
                SharedData.promptLogin(parentVC: self)
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
    
    /**
     Follow or unfollow a user.
     - Parameter sender: the object that triggered this event
     */
    @IBAction func followTapped(_ sender: Any) {
        // Send a request to the backend API to follow the user
        BackendAPI.followUser(username: self.username, successCallback: { (followed: Bool) in
            // Update UI and reload timeline
            DispatchQueue.main.async {
                if followed {
                    self.isFollowed = true
                    self.followButton.setTitle("Unfollow", for: [])
                } else {
                    self.isFollowed = false
                    self.followButton.setTitle("Follow", for: [])
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "followChanged"), object: nil)
            }
        })
    }
    
}
