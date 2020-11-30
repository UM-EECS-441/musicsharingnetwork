//
//  CreateProfileVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/24/20.
//

import UIKit

/**
 Display a form that lets the user create a new profile.
 */
class CreateProfileVC: UIViewController {
    
    // MARK: - User Interface
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get notifications when the user logs in or out
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardHelper))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - Event Handlers
    
    /**
     Respond when the user logs in or out.
     */
    @objc private func loginChanged() {
        if SharedData.logged_in {
            print("CreateProfileVC > loginChanged: User logged in")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("CreateProfileVC > loginChanged: User logged out")
        }
    }
    
    /**
     Dismiss the keyboard.
     */
    @objc private func dismissKeyboardHelper() {
        self.view.endEditing(false)
    }
    
    /**
     Dismiss the keyboard.
     - Parameter sender: object that triggered this event
     */
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.dismissKeyboardHelper()
    }
    
    /**
     Submit a request to create a new profile.
     - Parameter sender: object that triggered profile creation
     */
    @IBAction func createProfile(_ sender: Any) {
        // Store credential  inputs
        let username_input = self.usernameInput.text ?? ""
        let password_input = self.passwordInput.text ?? ""
        
        // Send a request to the create account API
        BackendAPI.createAccount(username: username_input, password: password_input, fullname: self.fullNameInput.text ?? "", bio: self.bioInput.text ?? "", successCallback: { (username: String) in
            DispatchQueue.main.async {
                // Update shared username variable
                SharedData.username = username
                // Save credentials
                UserDefaults.standard.setValue(username_input, forKey: "username")
                UserDefaults.standard.setValue(password_input, forKey: "password")
                // Tell everyone else we updated it
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
            }
        })
    }
}
