//
//  UserSearchVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/*
 Controls a view that shows a list of users similar to the username typed in
 the search bar.
 */
class UserSearchVC: UITableViewController {
    
    var results = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getUsers(nameBeginsWith: "")
    }
    
    // MARK: - API Calls
    
    func getUsers(nameBeginsWith: String) {
        // FIXME: Replace with an API call
        results = ["adithyaboddu", "adithyaboddu1", "frontend", "jazawisa", "stevejobs"]
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return self.results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let profileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.mine = false
        profileVC.username = self.results[indexPath.row]
        self.navigationController?.show(profileVC, sender: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableCell", for: indexPath) as? UserSearchTableCell else {
            fatalError("No reusable cell!")
        }
        
        cell.usernameLabel.text = self.results[indexPath.row]
        
        return cell
    }
    
    // MARK: - Event Handlers
}

