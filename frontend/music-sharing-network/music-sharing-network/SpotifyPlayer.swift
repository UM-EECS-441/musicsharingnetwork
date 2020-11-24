//
//  SpotifyPlayer.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/24/20.
//

import UIKit

class SpotifyPlayer: NSObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    static var shared = SpotifyPlayer()
    
    private static let SpotifyClientID = SharedData.spotifyClientID
    private static let SpotifyRedirectURI = URL(string: SharedData.spotifyCallbackURI)!
    
    // MARK: Session Manager
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyPlayer.SpotifyClientID, redirectURL: SpotifyPlayer.SpotifyRedirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://10.0.0.185:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://10.0.0.185:1234/refresh")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Spotify session failed")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Spotify session renewed")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Spotify session succeeded")
    }
    
    // MARK: App Remote
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Spotify player connected")
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Spotify player disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Spotify player failed")
    }
    
    // MARK: Player
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Spotify player state changed to track name: %@", playerState.track.name)
    }
    
    // MARK: App Delegate Callbacks
    
    func applicationDidBecomeActive() {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func applicationWillResignActive() {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
}
