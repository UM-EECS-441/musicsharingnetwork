//
//  TimelineVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit

class TimelineVC: UITableViewController {
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        getPosts()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getPosts()
    }
    
    func getPosts() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
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
                        self.posts.append(Post(identifier: postEntry["post_id"] as! String, timestamp: postEntry["timestamp"] as! String, owner: postEntry["owner"] as! String, media: postEntry["content"] as! String, message: postEntry["message"] as? String ?? postEntry["messsage"] as! String, likes: postEntry["num_likes"] as! Int, reposts: postEntry["num_reposts"] as! Int))
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
    }
    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableCell", for: indexPath) as? TimelineTableCell else {
            fatalError("No reusable cell!")
        }
        
        let post = self.posts[indexPath.row]
        cell.usernameLabel.text = post.owner
        cell.usernameLabel.sizeToFit()
        cell.timestampLabel.text = post.timestamp
        cell.timestampLabel.sizeToFit()
        cell.textBox.text = post.message
        cell.textBox.sizeToFit()
        
        let media = post.media.components(separatedBy: ":")
        cell.artistLabel.text = media.first
        cell.songLabel.text = media.last
         
        return cell
    }
}
