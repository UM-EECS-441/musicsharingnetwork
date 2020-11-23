//
//  SongView.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/3/20.
//

import UIKit

@IBDesignable
class SongView: UIView {
    let nibName = "SongView"
    var contentView: UIView?
    
    var song: String?
    weak var parentVC: UIViewController?
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.spotifyPlayerChanged), name: NSNotification.Name(rawValue: "spotifySessionChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.spotifyStateChanged), name: NSNotification.Name(rawValue: "spotifyStateChanged"), object: nil)
        
        self.spotifyPlayerChanged()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @objc func loginChanged() {
        self.shareButton.isHidden = !SharedData.logged_in
    }
    
    @objc func spotifyPlayerChanged() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("SongView > spotifyPlayerChanged: ERROR - Unable to get app delegate")
            return
        }
        
        self.playButton.isHidden = appDelegate.sessionManager.session == nil
    }
    
    @objc func spotifyStateChanged() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("SongView > spotifyStateChanged: ERROR - Unable to get app delegate")
            return
        }
        
        appDelegate.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                if playerState.track.uri == self?.song {
                    self?.playButton.setImage(UIImage(systemName: "pause.fill"), for: [])
                } else {
                    self?.playButton.setImage(UIImage(systemName: "play.fill"), for: [])
                }
            }
        })
    }
    
    @IBAction func shareButtonHandler(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let newMessageVC = storyBoard.instantiateViewController(withIdentifier: "ShareSongVC") as! ShareSongVC
        newMessageVC.song = self.song
        self.parentVC?.present(newMessageVC, animated: true, completion: nil)
    }
    
    /**
     Show a song in this view.
     - Parameter song: the song identifier
     - Parameter parentVC: the view controller displaying this song
     */
    func showSong(song: String, parentVC: UIViewController?) {
        self.parentVC = parentVC
        self.song = song
        
        let media = song.components(separatedBy: ":")
        self.artistLabel.text = media.first
        self.artistLabel.sizeToFit()
        self.songLabel.text = media.last
        self.songLabel.sizeToFit()
    }
}
