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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
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
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Submit a request to create a new profile.
     - Parameter sender: object that triggered profile creation
     */
    @IBAction func createProfile(_ sender: Any) {
        // Send a request to the create account API
        BackendAPI.createAccount(username: self.usernameInput.text ?? "", password: self.passwordInput.text ?? "", fullname: self.fullNameInput.text ?? "", bio: self.bioInput.text ?? "", successCallback: { (username: String) in
            DispatchQueue.main.async {
                // Update shared username variable
                SharedData.username = username
                // Tell everyone else we updated it
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
            }
        })
    }
}
