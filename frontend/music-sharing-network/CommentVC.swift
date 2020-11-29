//
//  CommentVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//

import UIKit

/**
 Display replies to a post.
 */
class CommentVC: UITableViewController {
    
    // MARK: - Variables
    
    // ID of the post
    var identifier: String = ""
    // Comments on the post
    private var comments = [Post]()
    
    // MARK: - User Interface
    
    @IBOutlet weak var newCommentButton: UIBarButtonItem!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Let the user refresh comments
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        // Hide or show the new comment button depending on whether the user is logged in
        if SharedData.logged_in {
            self.newCommentButton.image = UIImage(systemName: "plus")
            self.newCommentButton.isEnabled = true
        } else {
            self.newCommentButton.image = .none
            self.newCommentButton.isEnabled = false
        }
        
        // Load comments
        self.getComments()
    }
    
    // MARK: - Helpers
    
    /**
     Load comments.
     */
    private func getComments() {
        // Send a request to the get post info API
        BackendAPI.getPostInfo(identifier: self.identifier, successCallback: { (post: Post, replies: [Post]) in
            // Show the comments
            DispatchQueue.main.async {
                self.comments = replies
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
        })
    }
    
    // MARK: - Event Handlers
    
    /**
     Reload comments when the user initiates a refresh.
     - Parameter refreshControl: the refresh control that triggered this event
     */
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getComments()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "segueNewComment"){
            if let newCommentVC = segue.destination as? NewCommentVC{
                newCommentVC.identifier = self.identifier
                newCommentVC.commentCreated = { (comment: Post) in
                    DispatchQueue.main.async {
                        self.comments.append(comment)
                        self.tableView.rowHeight = UITableView.automaticDimension
                        self.tableView.reloadData()
                        if self.comments.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                        }
                    }
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
    
}

