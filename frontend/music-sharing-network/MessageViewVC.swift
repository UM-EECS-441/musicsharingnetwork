//
//  MessageViewVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/**
 Show all messages in a conversation.
 */
class MessageViewVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Variables
    
    // Conversation to show
    // (must be populated before the view is shown)
    var conversation: Conversation!
    // Messages in the conversation
    var messages = [Message]()
    
    // MARK: - User Interface
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            self.tableView.refreshControl = UIRefreshControl()
        }
    }
    @IBOutlet weak var messageInput: UITextField! {
        didSet {
            self.messageInput.returnKeyType = UIReturnKeyType.send
        }
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Respond when a message is sent from somewhere else in the app
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageSent), name: NSNotification.Name(rawValue: "messageSent"), object: nil)

        // Let the user refresh their messages
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        // Respond when the keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        // Respond when the keyboard is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Set the navigation bar title
        self.navBar.title = self.conversation.members.joined(separator: ", ")
        
        // Load messages
        self.getMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    // MARK: - Helpers
    
    /**
     Load messages.
     */
    private func getMessages() {
        // Send a request to the backend API to get messages
        BackendAPI.getMessages(identifier: self.conversation!.identifier, successCallback: { (messages: [Message]) in
            // Show the messages
            DispatchQueue.main.async {
                self.messages = messages
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
                if self.messages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
        })
    }

    // MARK: - TableView Handlers

    func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return messages.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        let message = messages[indexPath.row]
        let messageData = try! (JSONSerialization.jsonObject(with: message.text.data(using: .utf8)!) as! [String: String])
        
        if messageData["type"] == "text" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewTableCellText", for: indexPath) as? MessageViewTableCellText else {
                fatalError("No reusable cell!")
            }
            
            cell.usernameLabel.text = message.owner
            cell.usernameLabel.sizeToFit()
            cell.messageTextLabel.text = messageData["content"]
            cell.messageTextLabel.sizeToFit()
            
            return cell
        } else if messageData["type"] == "song" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewTableCellSong", for: indexPath) as? MessageViewTableCellSong else {
                fatalError("No reusable cell!")
            }
            
            cell.usernameLabel.text = message.owner
            cell.usernameLabel.sizeToFit()
            
            cell.songView.showSong(uri: messageData["content"] ?? "", parentVC: self)

            return cell
        } else {
            fatalError("Invalid type!")
        }
    }
    
    // MARK: - Event Handlers
    
    /**
     Reload messages when the user sends a message from somewhere else in the app.
     */
    @objc private func messageSent() {
        self.getMessages()
    }

    /**
     Reload messages when the user initiates a refresh.
     - Parameter refreshControl: refresh control that triggered this event
     */
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getMessages()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    /**
     Move the text box up so it is still visible when the keyboard is shown.
     - Parameter notification: notification that triggered this event
     */
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = 10 + keyboardSize.height - 50
        }
    }
    
    /**
     Move the text box down so it is back in its original location when the keyboard is hidden.
     - Parameter notification: notification that triggered this event
     */
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 10
    }
    
    /**
     Dismiss the keyboard.
     */
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Send a new message.
     - Parameter sender: object that triggered this event
     */
    @IBAction func sendMessage(_ sender: Any) {
        // Serialize the message into JSON data
        let messageText = try? JSONSerialization.data(withJSONObject: ["type": "text", "content": self.messageInput.text ?? ""] as [String: String])
        
        // Send a request to the backend API to send a message
        BackendAPI.sendMessage(recipients: self.conversation?.members ?? [], message: String(data: messageText!, encoding: .utf8) ?? "", successCallback: { (message: Message) in
            // Display the new message
            DispatchQueue.main.async {
                self.messages.append(message)
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
        
        // Dismiss the keyboard and clear the message input field
        self.view.endEditing(false)
        self.messageInput.text = ""
    }
}

