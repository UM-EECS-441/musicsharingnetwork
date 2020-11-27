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
        self.isModalInPresentation = !allowGuest
    }
    
    @objc func loginChanged() {
        if SharedData.logged_in {
            print("LoginVC > loginChanged: User logged in")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("LoginVC > loginChanged: User logged out")
        }
    }
    
    /*
     Sign in with the username and password supplied by the user.
     */
    @IBAction func login(_ sender: Any) {
        // Send a request to the backend to login
        BackendAPI.login(username: self.usernameInput.text ?? "", password: self.passwordInput.text ?? "", successCallback: { (username: String) in
            // Update shared username variable
            SharedData.username = username
            // Tell everyone else we updated it
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
            }
        }, errorCallback: {
            SharedData.presentAlertController(title: "Login Failed", message: "Login did not succeed. Did you type the correct username and password?", buttonTitle: "ok", parentVC: self)
        })
    }
}
