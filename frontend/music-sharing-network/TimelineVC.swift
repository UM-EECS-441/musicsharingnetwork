//
//  TimelineVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit

/**
 Display the user's feed. All posts by the user themself or by anyone they follow are included. If the user is not
 logged in, show all posts from all users.
 */
class TimelineVC: UITableViewController {
    
    // MARK: - Variables
    
    // List of posts to display
    private var posts = [Post]()
    
    // MARK: - User Interface
    
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Respond when the user logs in or out
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        // Respond when the user follows or unfollows another user
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "followChanged"), object: nil)
        // Respond when the user creates a new post
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "newPost"), object: nil)
        
        // Let the user refresh their feed
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        // Show the button to create a new post only if the user is logged in
        if SharedData.logged_in {
            self.newPostButton.image = UIImage(systemName: "plus")
            self.newPostButton.isEnabled = true
        } else {
            self.newPostButton.image = .none
            self.newPostButton.isEnabled = false
        }
        
        // Load posts
        self.getPosts()
    }
    
    // MARK: - Helpers
    
    /**
     Load posts.
     */
    private func getPosts() {
        // Send a request to the get posts API
        BackendAPI.getPosts(successCallback: { (posts: [Post]) in
            DispatchQueue.main.async {
                self.posts = posts
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Event Handlers
    
    /**
     Show or hide the appropriate UI elements and reload the feed when the user logs in or out.
     */
    @objc private func loginChanged() {
        if SharedData.logged_in {
            self.newPostButton.image = UIImage(systemName: "plus")
            self.newPostButton.isEnabled = true
        } else {
            self.newPostButton.image = .none
            self.newPostButton.isEnabled = false
        }
        
        self.getPosts()
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Reload the feed if the user follows or unfollows another user or creates a post.
     */
    @objc private func reload() {
        self.getPosts()
    }
    
    /**
     Reload the feed and end refreshing if the user initiates a refresh.
     - Parameter refreshControl: refresh control that triggered this event
     */
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getPosts()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "segueComments"){
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! TimelineTableCell
                if let commentVC = segue.destination as? CommentVC{
                    commentVC.identifier = cell.identifier!
                }
            }
        }
    }
    
    // MARK:- TableView Handlers

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
        cell.identifier = post.identifier
        cell.usernameLabel.text = post.owner
        cell.usernameLabel.sizeToFit()
        cell.timestampLabel.text = post.timestamp
        cell.timestampLabel.sizeToFit()
        cell.textBox.text = post.message
        cell.textBox.sizeToFit()
        cell.songView.showSong(uri: post.media, parentVC: self)
        //Set num_likes for each post
        cell.likeButton.setTitle(String(post.likes), for: .normal)
        // Show the post as liked or unliked
        if post.liked {
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        // Update like button icon and count for UI
        cell.likeButtonAction = { (liked: Bool) in
            if(liked) {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                post.likes = post.likes + 1
                post.liked = true
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                post.likes = post.likes - 1
                post.liked = false
            }
            cell.likeButton.setTitle(String(post.likes), for: .normal)
        }
        
        return cell
    }
    
}
