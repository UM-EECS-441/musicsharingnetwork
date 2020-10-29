//
//  MessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

/*
 Controls a view that shows a list of all the conversations the user is a member
 of. Conversations are identified by the set of members in them.
 */
class MessageListVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prompt the user to login if they have not already
        SharedData.login(parentVC: self, completion: nil)
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

/*
 Controls a view that shows the messages in a specific conversation.
 */
class MessageViewVC: UITableViewController {
    private var type: Bool = false // Temporary; used to make the static UI look good

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
        
        // This is a little trippy with the "type" variable, which will not be used for real.
        // When connecting this to the backend, choose which type of table cell to show based
        // who sent the message.
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
