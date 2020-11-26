//
//  SongView.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/3/20.
//

import UIKit

@IBDesignable
class SongView: UIView {
    // MARK: - Variables
    
    let nibName = "SongView"
    var contentView: UIView?
    
    weak var parentVC: UIViewController?
    
    var spotifyURI: String!
    var spotifyLink: String?
    
    // MARK: - User Interface
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        
        self.shareButton.isHidden = !SharedData.logged_in
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: - Event Handlers
    
    @objc func loginChanged() {
        self.shareButton.isHidden = !SharedData.logged_in
    }
    
    @IBAction func shareButtonHandler(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let newMessageVC = storyBoard.instantiateViewController(withIdentifier: "ShareSongVC") as? ShareSongVC else {
            print("SongView > shareButtonHandler - ERROR: Failed to instantiat view controller with identifier 'ShareSongVC'")
            return
        }
        newMessageVC.song = self.spotifyURI
        self.parentVC?.present(newMessageVC, animated: true, completion: nil)
    }
    
    @IBAction func speakerButtonHandler(_ sender: Any) {
        if let url = URL(string: self.spotifyLink ?? "https://open.spotify.com") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Showing Songs
    
    /**
     Show a song in this view.
     - Parameter uri: the song's Spotify URI
     - Parameter parentVC: the view controller displaying this song
     */
    func showSong(uri: String, parentVC: UIViewController?) {
        self.parentVC = parentVC
        
        // Send a request to the Spotify API to get info about this song
        SpotifyWebAPI.getTrack(uri: uri, callback: { (uri: String, link: String?, song: String?, album: String?, artist: String?, image: UIImage?) in
            // Update variables
            self.spotifyURI = uri
            self.spotifyLink = link
            
            // Update UI
            DispatchQueue.main.async {
                self.songLabel.text = song
                self.songLabel.sizeToFit()
                self.artistLabel.text = artist
                self.artistLabel.sizeToFit()
                self.albumArtImageView.image = image
                self.albumArtImageView.sizeToFit()
            }
        })
    }
    
    /**
     Show a song in this view.
     - Parameter uri: the song's Spotify URI
     - Parameter link: link to the song on Spotify
     - Parameter song: song name
     - Parameter album: album name
     - Parameter artist: artist name
     - Parameter image: album cover
     - Parameter parentVC: the view controller displaying this song
     */
    func showSong(uri: String, link: String?, song: String?, album: String?, artist: String?, image: UIImage?, parentVC: UIViewController?) {
        self.parentVC = parentVC
        
        // Update variables
        self.spotifyURI = uri
        self.spotifyLink = link
        
        // Update UI
        DispatchQueue.main.async {
            self.songLabel.text = song
            self.songLabel.sizeToFit()
            self.artistLabel.text = artist
            self.artistLabel.sizeToFit()
            self.albumArtImageView.image = image
            self.albumArtImageView.sizeToFit()
        }
    }
}
