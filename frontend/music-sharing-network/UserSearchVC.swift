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
class UserSearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Variables
    
    var results = [String]()
    
    // MARK: - User Interface
    
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }
    }
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    // MARK:- TableView handlers

    func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let profileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.myProfile = false
        profileVC.username = self.results[indexPath.row]
        self.navigationController?.show(profileVC, sender: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableCell", for: indexPath) as? UserSearchTableCell else {
            fatalError("No reusable cell!")
        }
        
        cell.usernameLabel.text = self.results[indexPath.row]
        
        return cell
    }
    
    // MARK: - Event Handlers
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @IBAction func executeSearch(_ sender: Any) {
        // Send a request to the backend API to search users
        BackendAPI.searchUsers(query: self.searchInput.text ?? "", successCallback: { (results: [String]) in
            // Show search results
            DispatchQueue.main.async {
                self.results = results
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        })
        
        // Dismiss keyboard and clear search input
        self.dismissKeyboard()
        self.searchInput.text = nil
    }
    
}

