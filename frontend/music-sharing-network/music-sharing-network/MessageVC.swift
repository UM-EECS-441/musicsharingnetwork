//
//  MessageVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

class Conversation {
    var identifier: String
    var members: [String]
    
    init(identifier: String, members: [String]) {
        self.identifier = identifier
        self.members = members
    }
}

class MessageListTableCell: UITableViewCell {
    
    var identifier: String?
    
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

/*
 Controls a view that shows a list of all the conversations the user is a member
 of. Conversations are identified by the set of members in them.
 */
class MessageListVC: UITableViewController {
    
    var conversations = [Conversation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        // Prompt the user to login if they have not already
        SharedData.login(parentVC: self) { () in
            self.getConversations()
        }

    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getConversations()
    }

    func getConversations() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        let (data, response, error) = SharedData.SynchronousHTTPRequest(request)

        // Check for errors
        guard let _ = data, error == nil else {
            print("MessageListVC > getConversations: NETWORKING ERROR")
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            // Check for errors
            if httpResponse.statusCode != 200 {
                print("MessageListVC > getConversations: HTTP STATUS: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }

            do {
                self.conversations = [Conversation]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let conversations = json["conversations"] as! [[String: Any]]

                for convo in conversations {
                    self.conversations.append(Conversation(identifier: convo["conversation_id"] as! String, members: convo["members"] as! [String]))
                }
                DispatchQueue.main.async {
                    self.tableView.rowHeight = UITableView.automaticDimension
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }

    // MARK:- TableView handlers

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
}

class Message {
    var identifier: String
    var timestamp: String
    var owner: String
    var text: String

    init(identifier: String, timestamp: String, owner: String, text: String) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.owner = owner
        self.text = text
    }
}

class MessageViewTableCell: UITableViewCell {
    
    var owner: String?
    var identifier: String?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

/*
 Controls a view that shows the messages in a specific conversation.
 */
class MessageViewVC: UITableViewController {
    var conversation: Conversation?
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        // Prompt the user to login if they have not already
        SharedData.login(parentVC: self) { () in
            self.getMessages()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getMessages()
    }

    func getMessages() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/\(self.conversation!.identifier)/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        let (data, response, error) = SharedData.SynchronousHTTPRequest(request)

        // Check for errors
        guard let _ = data, error == nil else {
            print("MessageViewVC > getConversations: NETWORKING ERROR")
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            // Check for errors
            if httpResponse.statusCode != 200 {
                print("MessageViewVC > getConversations: HTTP STATUS: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
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
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }

    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return messages.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewTableCell", for: indexPath) as? MessageViewTableCell else {
            fatalError("No reusable cell!")
        }

        let message = messages[indexPath.row]
        cell.usernameLabel.text = message.owner
        cell.usernameLabel.sizeToFit()
        
        let media = message.text.components(separatedBy: ":")
        cell.songArtist.text = media[0]
        cell.songArtist.sizeToFit()
        cell.songTitle.text = media[1]
        cell.songTitle.sizeToFit()

        return cell
    }
    
}

class NewMessageVC: UIViewController {
    var song: String?
    var artist: String?
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var recipientInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.artist = self.songArtistLabel.text
        self.song = self.songTitleLabel.text
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonHandler(_ sender: Any) {
        // Send the song title and artist as the message text
        let message = self.artist! + ":" + self.song!
        
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["recipients": [self.recipientInput.text ?? ""], "message": message]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/messages/send"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        let (data, response, error) = SharedData.SynchronousHTTPRequest(request)
        
        // Check for errors
        guard let _ = data, error == nil else {
            print("NewMessageVC > sendButtonHandler: NETWORKING ERROR")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            // Check for errors
            if httpResponse.statusCode != 201 {
                print("NewMessageVC > sendButtonHandler: HTTP STATUS: \(httpResponse.statusCode)")
                return
            }
            
            // Mark the user as logged in by saving their username,
            // and dismiss the login screen
            self.dismiss(animated: true, completion: nil)
        }
    }
}
