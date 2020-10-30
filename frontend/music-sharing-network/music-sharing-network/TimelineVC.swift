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

class TimelineVC: UITableViewController {

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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableCell", for: indexPath)
        
        return cell
    }
}
