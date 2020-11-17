//
//  TimelineTableCell.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

class TimelineTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var songView: SongView!
    @IBOutlet weak var textBox: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var likeButtonAction : (() -> Void)?
    var isLiked: Bool = false
    var isFollowed: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.likeButton.addTarget(self, action: #selector(likeTapped(_:)), for: .touchUpInside)
    }
    
    @IBAction func followTapped(_ sender: Any) {
        
        self.isFollowed.toggle()
        
        if isFollowed {
            
            // API request to follow user
            //let json: [String: Any] = ["username": targetUser]
            //let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            // Build an HTTP request
            let targetUser: String = self.usernameLabel.text ?? "ERROR"
            let requestURL = SharedData.baseURL + "/users/" + targetUser + "/follow/"
            var request = URLRequest(url: URL(string: requestURL)!)
            request.httpShouldHandleCookies = true
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.httpBody = jsonData
            
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
            
            // API request to follow user
            //let json: [String: Any] = ["username": targetUser]
            //let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            // Build an HTTP request
            let targetUser: String = self.usernameLabel.text ?? "ERROR"
            let requestURL = SharedData.baseURL + "/users/" + targetUser + "/unfollow/"
            var request = URLRequest(url: URL(string: requestURL)!)
            request.httpShouldHandleCookies = true
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.httpBody = jsonData
            
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
    
    @IBAction func likeTapped(_ sender: Any) {
        
        self.isLiked.toggle()
        self.likeButtonAction?()
        
        /* HTTP Request [API endpoint needs to be made]
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["post_id": identifier]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/" + identifier! + "/like/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("TimelineTableCellVC > likeTapped: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("TimelineTableCellVC > likeTapped: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
            }
        }
         */
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}
