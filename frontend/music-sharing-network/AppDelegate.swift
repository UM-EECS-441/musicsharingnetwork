//
//  AppDelegate.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/9/20.
//

import UIKit
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("credentials")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Load username and login
        if let saved_username: String = UserDefaults.standard.string(forKey: "username") {
            if let saved_password = UserDefaults.standard.string(forKey: "password") {
                BackendAPI.login(username: saved_username, password: saved_password, successCallback: { (username: String) in
                    DispatchQueue.main.async {
                        // Update shared username variable
                        SharedData.username = username
                        // Save credentials
                        UserDefaults.standard.setValue(saved_username, forKey: "username")
                        UserDefaults.standard.setValue(saved_password, forKey: "password")
                        // Tell everyone we logged in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                    }
                })
            }
        }
        
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
    
}

