//
//  SettingsVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/29/20.
//

import UIKit

class SettingsVC: UIViewController {
    
    // MARK: - User Interface
    
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput: UITextField!
    
    // MARK: - Initilization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardHelper))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - Event Handlers
    
    /**
     Dismiss the keyboard.
     */
    @objc func dismissKeyboardHelper() {
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
     Change the user's password.
     */
    @IBAction func saveButtonHandler(_ sender: Any) {
        // Send a request to the change pasword API
        BackendAPI.changePassword(old: self.oldPasswordInput.text ?? "", new: self.newPasswordInput.text ?? "")
        
        // Reset the password fields
        self.oldPasswordInput.text = nil
        self.newPasswordInput.text = nil
    }
    
    /**
     Log out of the current user's account.
     - Parameter sender: the object that triggered this event
     */
    @IBAction func logoutButtonHandler(_ sender: Any) {
        // Send a request to the logout API
        BackendAPI.logout(successCallback: { () in
            DispatchQueue.main.async {
                // Reset username
                SharedData.username = ""
                // Reset saved credentials
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.removeObject(forKey: "password")
                // Tell everyone we changed it
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
            }
        })
    }
}

