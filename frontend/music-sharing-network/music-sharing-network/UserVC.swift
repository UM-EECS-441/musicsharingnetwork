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
    var mine: Bool = true
    // If not, whose profile are they viewing?
    var username: String = ""
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var bioBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the user is viewing their own profile, hide the follow button and
        // make sure they're logged in. If the user is viewing someone else's
        // profile, hide the settings button and set the navBar title to be the
        // username of whoever we're viewing.
        if mine {
            self.followButton.isHidden = true
            SharedData.login(parentVC: self) { () in
                self.username = SharedData.username
                self.getProfile()
            }
        } else {
            self.navBar.rightBarButtonItems?.removeAll()
            self.navBar.title = self.username
            self.getProfile()
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
        let (data, response, error) = SharedData.SynchronousHTTPRequest(request)
        
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
            }
        }
    }
    
}

/*
 Controls a view that shows a list of users similar to the username typed in
 the search bar.
 */
class UserSearchVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableCell", for: indexPath)
        
        return cell
    }
    
    // MARK: - Storyboard Segues
    
    // FIXME: Probably want to use one of the tableview functions instead of this
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileVC = segue.destination as? ProfileVC {
            profileVC.mine = false
            profileVC.username = "frontend"
        }
    }
    
}
