//
//  SettingsVC.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/29/20.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
    }
    
    @IBAction func loginChanged() {
        if SharedData.logged_in {
            print("SettingsVC > loginChanged: User logged in")
        } else {
            print("SettingsVC > loginChanged: User logged out")
            
            // Exit the settings screen since the user is now logged out
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonHandler(_ sender: Any) {
        // Send a request to the change pasword API
        BackendAPI.changePassword(old: self.oldPasswordInput.text ?? "", new: self.newPasswordInput.text ?? "")
        
        // Reset the password fields
        self.oldPasswordInput.text = nil
        self.newPasswordInput.text = nil
    }
    
    @IBAction func logoutButtonHandler(_ sender: Any) {
        // Send a request to the logout API
        BackendAPI.logout(successCallback: { () in
            // Reset username
            SharedData.username = ""
            // Tell everyone we changed it
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
            }
        })
    }
}

