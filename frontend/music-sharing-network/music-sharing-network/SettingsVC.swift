//
//  SettingsVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/29/20.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spotifyButton.isHidden = !SpotifyPlayer.shared.sessionManager.isSpotifyAppInstalled
    }
    
    @IBAction func saveButtonHandler(_ sender: Any) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["old_password": self.oldPasswordInput.text ?? "", "new_password": self.newPasswordInput.text ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/password/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request){ (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SettingsVC > saveButtonHandler: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 204 {
                    print("SettingsVC > saveButtonHandler: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
            }
        }
        
    }
    
    @IBAction func logoutButtonHandler(_ sender: Any) {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/logout/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SettingsVC > logoutButtonHandler: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("SettingsVC > logoutButtonHandler: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Reset username
                SharedData.username = ""
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                
                // Exit the settings screen since the user is now logged out
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

