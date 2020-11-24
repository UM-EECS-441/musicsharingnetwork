//
//  NewCommentVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//

import UIKit

class NewCommentVC: UIViewController {
    
    @IBOutlet weak var commentInput: UITextField!
    
    var identifier: String = ""
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Prompt the user to login if they have not already
        SharedData.login(parentVC: self, completion: nil)
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addComment(_ sender: Any) {
        // Serialize the username and password into JSON data
        let json: [String: Any] = ["message": self.commentInput.text ?? "", "content": "COMMENT", "reply_to": self.identifier]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/posts/create/"
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
                print("NewCommentVC > addComment: NETWORKING ERROR")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != 201 {
                    print("NewCommentVC > addComment: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
                
                // Mark the user as logged in by saving their username,
                // and dismiss the login screen
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
