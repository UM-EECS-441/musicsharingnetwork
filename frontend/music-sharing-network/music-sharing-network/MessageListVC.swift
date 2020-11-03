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
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
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