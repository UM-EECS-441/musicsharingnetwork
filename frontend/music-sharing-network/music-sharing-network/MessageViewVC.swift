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
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
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
        
        cell.songView.showSong(song: message.text, parentVC: self)

        return cell
    }
    
}

