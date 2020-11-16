//
//  MessageViewVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/3/20.
//

import UIKit

/*
 Controls a view that shows the messages in a specific conversation.
 */
class MessageViewVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var conversation: Conversation?
    var messages = [Message]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }
    }
    @IBOutlet weak var messageInput: UITextField! {
        didSet {
            self.messageInput.returnKeyType = UIReturnKeyType.send
        }
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        // Prompt the user to login if they have not already
        SharedData.login(parentVC: self) { () in
            self.getMessages()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getMessages()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = 10 + keyboardSize.height - 50
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 10
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func getMessages() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/\(self.conversation!.identifier)/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("MessageViewVC > getConversations: NETWORKING ERROR")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("MessageViewVC > getConversations: HTTP STATUS: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    return
                }

                do {
                    self.messages = [Message]()
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let messages = json["messages"] as! [[String: Any]]

                    for message in messages {
                        self.messages.append(Message(identifier: message["id"] as! String, timestamp: message["timestamp"] as! String, owner: message["owner"] as! String, text: message["message"] as! String))
                    }
                    DispatchQueue.main.async {
                        self.tableView.rowHeight = UITableView.automaticDimension
                        self.tableView.reloadData()
                        self.tableView.refreshControl?.endRefreshing()
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }

    // MARK:- TableView handlers

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewTableCellSong", for: indexPath) as? MessageViewTableCellSong else {
            fatalError("No reusable cell!")
        }

        let message = messages[indexPath.row]
        cell.usernameLabel.text = message.owner
        cell.usernameLabel.sizeToFit()
        
        cell.songView.showSong(song: message.text, parentVC: self)

        return cell
    }
    
    // MARK: - Event Handlers
    
    @IBAction func sendMessage(_ sender: Any) {
        print("Sending message")
        self.view.endEditing(false)
        self.messageInput.text = ""
    }
}

