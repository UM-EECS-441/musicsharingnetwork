//
//  SongView.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/3/20.
//

import UIKit
import SafariServices

@IBDesignable
class SongView: UIView {
    // MARK: - Variables
    
    let nibName = "SongView"
    var contentView: UIView?
    
    var song: String?
    var link: String?
    weak var parentVC: UIViewController?
    
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
        let newMessageVC = storyBoard.instantiateViewController(withIdentifier: "ShareSongVC") as! ShareSongVC
        newMessageVC.song = self.song
        self.parentVC?.present(newMessageVC, animated: true, completion: nil)
    }
    
    @IBAction func speakerButtonHandler(_ sender: Any) {
        if let url = URL(string: self.link ?? "https://open.spotify.com") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Showing Songs
    
    /**
     Show a song in this view.
     - Parameter song: the song identifier
     - Parameter parentVC: the view controller displaying this song
     */
    func showSong(song: String, parentVC: UIViewController?) {
        self.parentVC = parentVC
        self.song = song
        
        SpotifyWebAPI.getTrack(uri: song, callback: { (link: String, image: UIImage, song: String, artist: String) in
            self.link = link
            
            DispatchQueue.main.async {
                self.artistLabel.text = artist
                self.artistLabel.sizeToFit()
                self.songLabel.text = song
                self.songLabel.sizeToFit()
                self.albumArtImageView.image = image
                self.albumArtImageView.sizeToFit()
            }
        })
    }
}
