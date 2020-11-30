//
//  ExploreVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/27/20.
//

import UIKit

/**
 Display song recommendations.
 */
class ExploreVC: UITableViewController {

    // MARK: - Variables
    
    // List of song recommendations
    private var recommendations = [String]()
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Respond when the user logs in or out
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        // Let the user refresh their recommendations
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        // Load recommendations
        self.getRecommendations()
    }
    
    // MARK: - Helpers
    
    /**
     Load recommendations.
     */
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
    
    // MARK:- TableView Handlers

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
    
    // MARK: - Event Handlers
    
    /**
     Reload recommendations when the user logs in or out.
     */
    @objc private func reload() {
        self.getRecommendations()
    }
    
    /**
     Reload recommendations when the user initiates a refresh.
     - Parameter refreshControl: refresh control that triggered this event
     */
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getRecommendations()
        self.refreshControl?.endRefreshing()
    }
    
}
