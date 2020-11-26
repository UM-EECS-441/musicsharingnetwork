//
//  ExploreVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

class ExploreVC: UITableViewController {

    var recommendations = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
    }

    @objc func loginChanged() {
        if !SharedData.logged_in {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func getRecommendations() {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/recommendations/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("ExploreVC > getRecommendations: HTTP STATUS: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }
                    return
                }

                do {
                    self.recommendations = [String]()
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let recList = json["songs"] as! [String]
                    
                    for recEntry in recList {
                        self.recommendations.append(recEntry)
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTableCell", for: indexPath) as? ExploreTableCell else {
            fatalError("No reusable cell!")
        }
        
        cell.songView.showSong(uri: "Artist:Song", parentVC: self)
        
        return cell
    }
}
