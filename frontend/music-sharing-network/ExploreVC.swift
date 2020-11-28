//
//  ExploreVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

class ExploreVC: UITableViewController {

    private var recommendations = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "followChanged"), object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        self.getRecommendations()
    }

    @objc private func reload() {
        self.getRecommendations()
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getRecommendations()
        self.refreshControl?.endRefreshing()
    }
    
    private func getRecommendations() {
        // Send a request to the backend API to get recommendations
        BackendAPI.getRecommendations(successCallback: { (recommendations: [String]) in
            // Show the recommendations
            DispatchQueue.main.async {
                self.recommendations = recommendations
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return self.recommendations.count
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
        
        cell.songView.showSong(uri: self.recommendations[indexPath.row], parentVC: self)
        
        return cell
    }
}
