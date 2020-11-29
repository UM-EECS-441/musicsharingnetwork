//
//  NewCommentVC.swift
//  music-sharing-network
//
//  Created by Andrew on 11/20/20.
//

import UIKit

/**
 Display a form for the user to comment on a post.
 */
class NewCommentVC: UIViewController {
    
    // MARK: - Variables
    
    // ID of post to comment on
    var identifier: String = ""
    
    // MARK: - User Interface
    
    @IBOutlet weak var commentInput: UITextField!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard when the user taps anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - Event Handlers
    
    /**
     Dismiss the keyboard.
     */
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    /**
     Cancel comment creation by dismissing the view.
     - Parameter sender: object that triggered this event
     */
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Submit the new comment.
     - Parameter sender: object that triggered this event
     */
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
