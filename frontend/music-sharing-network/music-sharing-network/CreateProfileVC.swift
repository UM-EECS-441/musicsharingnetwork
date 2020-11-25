//
//  CreateProfileVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/24/20.
//

import UIKit

class CreateProfileVC: UIViewController {
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var bioInput: UITextField!
    
    private var presentingController: UIViewController?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentingController = presentingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createProfile(_ sender: Any) {
        let json: [String: String] = ["username": usernameInput.text ?? "", "password": passwordInput.text ?? "", "full_name": fullNameInput.text ?? "", "user_bio": bioInput.text ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/create/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request and read the server's response
        SharedData.SynchronousHTTPRequest(request){ (data, response, error) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("CreateProfileVC > createProfile: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("CreateProfileVC > createProfile: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
            }
        }
        //SharedData.username = usernameInput.text ?? ""
        dismiss(animated: false, completion: {
            self.presentingController?.dismiss(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        })
    }
    
}
