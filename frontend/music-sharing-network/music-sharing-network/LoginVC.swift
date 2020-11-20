//
//  LoginVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/28/20.
//

import UIKit

/*
 Controls a view that prompts the user to login.
 */
class LoginVC: UIViewController {
    // Should we allow the user to continue as a guest without signing in?
    var allowGuest = true
    
    // Closure to run once the user is logged in
    var completion: ((String) -> Void)?
    
    // Username and password fields
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    // Buttons to sign in or skip
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        // Hide the continue as guest button if necessary
        continueAsGuestButton.isHidden = !allowGuest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func loginChanged() {
        if SharedData.logged_in {
            self.close()
        }
    }
    
    @objc func objc_close() {
        self.close()
    }
    
    func close() {
        print("Dismissing LoginVC")
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     Sign in with the username and password supplied by the user.
     */
    @IBAction func login(_ sender: Any) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["username": self.usernameInput.text ?? "", "password": self.passwordInput.text ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/login/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request) { (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("LoginVC > login: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 200 {
                    print("LoginVC > login: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Mark the user as logged in by saving their username,
                // and dismiss the login screen
                self.completion?(self.usernameInput.text!)
                self.close()
            }
        }
    }
}
