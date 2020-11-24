//
//  CommentVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//


import UIKit


class CommentVC: UITableViewController {
    var comments = [Comment]()
    var identifier: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.refreshControl?.addTarget(self, action: #selector(CommentVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        getComments()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getComments()
    }
    
    func getComments() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/\(self.identifier)/info/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("CommentVC > getComments: HTTP STATUS: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }
                    return
                }

                do {
                    self.comments = [Comment]()
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let commentList = json["replies"] as! [[String: Any]]

                    for commentEntry in commentList {
                        self.comments.append(Comment(identifier: commentEntry["post_id"] as! String, timestamp: commentEntry["timestamp"] as! String, owner: commentEntry["owner"] as! String, message: commentEntry["message"] as! String))
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
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCell", for: indexPath) as? CommentTableCell else {
            fatalError("No reusable cell!")
        }
        
        let comment = self.comments[indexPath.row]
        cell.identifier = comment.identifier
        cell.usernameLabel.text = comment.owner
        cell.usernameLabel.sizeToFit()
        cell.timestampLabel.text = comment.timestamp
        cell.timestampLabel.sizeToFit()
        cell.commentContent.text = comment.message
        cell.commentContent.sizeToFit()
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "segueNewComment"){
            if let newCommentVC = segue.destination as? NewCommentVC{
                newCommentVC.identifier = self.identifier
            }
        }
    }
}

