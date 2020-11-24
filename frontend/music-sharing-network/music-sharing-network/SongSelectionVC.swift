//
//  SongSelectionVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

class SongSelectionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var results: [String] = [String]()
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.nextButton.isEnabled = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    // MARK: TableView Handlers
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return results.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        self.nextButton.isEnabled = true
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongSelectionTableCell", for: indexPath) as? SongSelectionTableCell else {
            fatalError("No reusable cell!")
        }
        
        let song: String = self.results[indexPath.row]
        cell.songView.showSong(song: song, parentVC: self)
        
        return cell
    }
    
    // MARK: Event Handlers
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NewPostVC {
            destination.song = self.results[self.tableView.indexPathForSelectedRow!.row]
        }
    }
    
    @IBAction func executeSearch(_ sender: Any) {
        self.results = SpotifyWebAPI.search(query: self.searchInput.text ?? "")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
        
        self.nextButton.isEnabled = false
        self.dismissKeyboard()
    }
}
