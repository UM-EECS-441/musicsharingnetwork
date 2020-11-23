//
//  AppDelegate.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    // MARK: - Spotify Integration
    
    private let SpotifyClientID = "c0a5c9b2c5b94d00b5599dd76b092414"
    private let SpotifyRedirectURI = URL(string: "music-sharing-network://spotify-login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifySessionChanged"), object: nil)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Spotify session renewed")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifySessionChanged"), object: nil)
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Spotify session succeeded")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifySessionChanged"), object: nil)
    }
    
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifyPlayerChanged"), object: nil)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Spotify player disconnected")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifyPlayerChanged"), object: nil)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Spotify player failed")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifyPlayerChanged"), object: nil)
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Spotify player state changed")
        debugPrint("Track name: %@", playerState.track.name)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spotifyStateChanged"), object: nil)
    }
}

