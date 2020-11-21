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
    
    var likeButtonAction : (() -> Void)?
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.likeButton.addTarget(self, action: #selector(likeTapped(_:)), for: .touchUpInside)
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["post_id": self.identifier!]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/\(self.identifier!)/like"
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
                if httpResponse.statusCode != 200 {
                    print("TimelineTableCellVC > likeTapped: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    self.isLiked = json["liked"] as! Bool

                    self.likeButtonAction?()
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
