//
//  TimelineVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit

class TimelineVC: UITableViewController {
    
    var posts = [Post]()
    
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.followChanged), name: NSNotification.Name(rawValue: "followChanged"), object: nil)
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        if SharedData.logged_in {
            self.newPostButton.image = UIImage(systemName: "plus")
        } else {
            self.newPostButton.image = .none
        }
        self.newPostButton.isEnabled = SharedData.logged_in
        self.getPosts()
    }
    
    @objc func loginChanged() {
        self.newPostButton.isEnabled = SharedData.logged_in
        
        if SharedData.logged_in {
            self.newPostButton.image = UIImage(systemName: "plus")
            self.getPosts()
        } else {
            self.newPostButton.image = .none
            self.getPosts()
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func followChanged() {
        self.getPosts()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getPosts()
        self.refreshControl?.endRefreshing()
    }
    
    func getPosts() {
        // Send a request to the get posts API
        BackendAPI.getPosts(successCallback: { (posts: [Post]) in
            DispatchQueue.main.async {
                self.posts = posts
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        })
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
}
