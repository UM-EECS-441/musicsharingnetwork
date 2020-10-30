//
//  TimelineVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit

class Post {
    var identifier: String
    var timestamp: String
    var owner: String
    var media: String
    var message: String
    var likes: Int
    var reposts: Int
    
    init(identifier: String, timestamp: String, owner: String, media: String,
         message: String, likes: Int, reposts: Int) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.media = media
        self.message = message
        self.likes = likes
        self.reposts = reposts
    }
}

class TimelineTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class TimelineVC: UITableViewController {
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func getPosts() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        let (data, response, error) = SharedData.SynchronousHTTPRequest(request)

        // Check for errors
        guard let _ = data, error == nil else {
            print("TimelineVC > getPosts: NETWORKING ERROR")
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            // Check for errors
            if httpResponse.statusCode != 200 {
                print("TimelineVC > getPosts: HTTP STATUS: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }

            do {
                self.posts = [Post]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let postList = json["posts"] as! [[String: Any]]

                for postEntry in postList {
                    self.posts.append(Post(identifier: postEntry["post_id"] as! String, timestamp: postEntry["timestamp"] as! String, owner: postEntry["owner"] as! String, media: postEntry["content"] as! String, message: postEntry["message"] as! String, likes: postEntry["num_likes"] as! Int, reposts: postEntry["num_reposts"] as! Int))
                }
                DispatchQueue.main.async {
                    self.tableView.rowHeight = UITableView.automaticDimension
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error)
            }
        }
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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableCell", for: indexPath)
         
        return cell
    }
}
