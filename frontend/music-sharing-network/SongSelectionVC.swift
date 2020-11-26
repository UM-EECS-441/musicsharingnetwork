//
//  SongSelectionVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/23/20.
//

import UIKit

class SongSelectionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var results = [(uri: String, link: String?, song: String?, album: String?, artist: String?, image: UIImage?)]()
    
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
        
        let item = self.results[indexPath.row]
        cell.songView.showSong(uri: item.uri, link: item.link, song: item.song, album: item.album, artist: item.artist, image: item.image, parentVC: self)
        cell.songView.shareButton.isHidden = true
        
        return cell
    }
    
    // MARK: Event Handlers
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? NewPostVC {
            destinationVC.song = self.results[self.tableView.indexPathForSelectedRow!.row].song
        }
    }
    
    @IBAction func executeSearch(_ sender: Any) {
        SpotifyWebAPI.search(query: self.searchInput.text ?? "") { (results: [(uri: String, link: String?, song: String?, album: String?, artist: String?, image: UIImage?)]) in
            DispatchQueue.main.async {
                self.results = results
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
                
                self.nextButton.isEnabled = false
                self.dismissKeyboard()
            }
        }
    }
}
