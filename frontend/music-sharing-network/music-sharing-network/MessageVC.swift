//
//  MessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

class MessageListVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prompt the user to login if they have not already
        if SharedData.cookie == nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.showDetailViewController(loginVC, sender: nil)
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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageListTableCell", for: indexPath)
        
        return cell
    }
}

class MessageViewVC: UITableViewController {
    private var type: Bool = false

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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        var id: String
        if(type) {
            id = "MessageViewTableCellReceived"
        } else {
            id = "MessageViewTableCellSent"
        }
        
        type = !type
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        return cell
    }
}
