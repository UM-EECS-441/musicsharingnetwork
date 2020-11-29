//
//  MessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

/**
 Display a list of all conversations the user is a member of.
 Conversations are identified by the set of members in them.
 */
class MessageListVC: UITableViewController {
    
    // MARK: - Variables
    
    // List of conversations
    private var conversations = [Conversation]()
    
    // MARK: - User Interface
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Let the user refresh their conversation list
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        // Respond when the user logs in or out
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        // Respond when a message is sent by the user
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageSent), name: NSNotification.Name(rawValue: "messageSent"), object: nil)

        // Hude or show the new message button depending on whether the user is logged in
        if SharedData.logged_in {
            self.composeButton.image = UIImage(systemName: "square.and.pencil")
            self.composeButton.isEnabled = true
            
            // If they are, retrieve a list of all their conversations
            self.getConversations()
        } else {
            self.composeButton.image = .none
            self.composeButton.isEnabled = false
            
            // If they're not, prompt them to login
            SharedData.promptLogin(parentVC: self, parentView: self.view.superview ?? self.view)
        }
    }
    
    // MARK: - Helpers
    
    /**
     Load conversations.
     */
    func getConversations() {
        // Send a request to the backend API to get conversations
        BackendAPI.getConversations(successCallback: { (conversations: [Conversation]) in
            DispatchQueue.main.async {
                self.conversations = conversations
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK:- TableView Handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        let conversation = conversations[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let messageViewVC = storyBoard.instantiateViewController(withIdentifier: "MessageViewVC") as! MessageViewVC
        messageViewVC.conversation = conversation
        self.navigationController?.show(messageViewVC, sender: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListTableCell", for: indexPath) as? MessageListTableCell else {
            fatalError("No reusable cell!")
        }

        let conversation = conversations[indexPath.row]
        cell.identifier = conversation.identifier
        cell.membersLabel.text = conversation.members.joined(separator: ", ")
        cell.membersLabel.sizeToFit()

        return cell
    }
    
    // MARK: - Event Handlers
    
    /**
     Reload conversations when a message is sent.
     */
    @objc func messageSent() {
        self.getConversations()
    }
    
    /**
     Reload conversations when the user initiates a refresh.
     */
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getConversations()
        self.refreshControl?.endRefreshing()
    }
    
    /**
     Hide or show the new message button and reload conversations when the user logs in or out.
     */
    @objc func loginChanged() {
        // Check whether the user logged in or out
        if SharedData.logged_in {
            // User logged in
            print("MessageListVC > loginChanged: User logged in")
            
            self.getConversations()
            
            self.composeButton.image = UIImage(systemName: "square.and.pencil")
            self.composeButton.isEnabled = true
        } else {
            // User logged out
            print("MessageListVC > loginChanged: User logged out")
            self.conversations.removeAll()
            self.tableView.reloadData()
            
            self.composeButton.image = .none
            self.composeButton.isEnabled = false
            self.navigationController?.popToRootViewController(animated: true)
            
            SharedData.promptLogin(parentVC: self, parentView: self.view.superview ?? self.view)
        }
    }
    
}
