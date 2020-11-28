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
        // Send a request to the backend create post API
        BackendAPI.createPost(content: "COMMENT", message: self.commentInput.text ?? "", replyTo: self.identifier, successCallback: { (post: Post) in
            // Dismiss the view since the comment has been created
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}
