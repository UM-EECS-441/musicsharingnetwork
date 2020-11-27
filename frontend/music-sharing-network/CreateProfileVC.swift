//
//  CreateProfileVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/24/20.
//

import UIKit

class CreateProfileVC: UIViewController {
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
    }
    
    @objc func loginChanged() {
        if SharedData.logged_in {
            print("CreateProfileVC > loginChanged: User logged in")
            self.dismiss(animated: true, completion: nil)
        } else {
            print("CreateProfileVC > loginChanged: User logged out")
        }
    }
    
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
