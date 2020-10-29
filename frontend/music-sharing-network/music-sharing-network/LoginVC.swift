//
//  LoginVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/28/20.
//

import UIKit

class LoginVC: UIViewController {
    // Should we allow the user to continue as a guest wirhour signing in?
    var allowGuest = true
    
    // Username and password fields
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    // Buttons to sign in or skip
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the continue as guest button if necessary
        continueAsGuestButton.isHidden = !allowGuest
    }
    
    // Sign in with the username and password supplied by the user
    @IBAction func login(_ sender: Any) {
        let json: [String: String] = ["username": self.usernameInput.text ?? "", "password": self.passwordInput.text ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let requestURL = SharedData.baseURL + "/users/login/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let sem = DispatchSemaphore.init(value: 0)
        var success = false
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("LoginVC > login: NETWORKING ERROR")
                sem.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("LoginVC > login: HTTP STATUS: \(httpResponse.statusCode)")
                    sem.signal()
                    return
                }
                
                SharedData.setCookie(httpResponse)
                sem.signal()
                success = true
            }
        }
        task.resume()
        
        sem.wait()
        if success { self.dismiss(animated: true, completion: nil) }
    }
}
