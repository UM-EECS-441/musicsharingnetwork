//
//  SharedData.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/28/20.
//

import UIKit

/*
 Store data and implementation that is used across many view controllers.
 */
class SharedData {
    // Current user's username (empty if not logged in)
    static var username: String = ""
    // Computed property to quickly check whether the user is logged in
    static var logged_in: Bool {
        get {
            !self.username.isEmpty
        }
    }
    
    /**
     Prompt the user to login by displaying a login button in the center of the screen.
     - Parameter parentVC: view controller to present the login form
     - Parameter parentView: view in which to show the login prompt
     */
    static func promptLogin(parentVC: UIViewController) {
        DispatchQueue.main.async {
            let loginView = LoginPromptView(frame: parentVC.view.bounds)
            loginView.backgroundColor = UIColor.white
            loginView.parentVC = parentVC
            parentVC.view.addSubview(loginView)
            parentVC.view.bringSubviewToFront(loginView)
        }
    }
    
    /**
     Send an asynchronous HTTP request and execute a block of code once the response is received.
     
     - Parameter request: the HTTP request to be sent
     - Parameter expectedResponseCode: response code that indicates a success
     - Parameter successCallback: function to execute if the request succeeds
     - Parameter errorCallback: function to execute if the request fails
     */
    static func HTTPRequest(request: URLRequest, expectedResponseCode: Int, successCallback: ((Data?, URLResponse?, Error?) -> Void)? = nil, errorCallback: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SharedData > HTTPRequest - ERROR: Invalid HTTP response")
                errorCallback?(data, response, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != expectedResponseCode {
                    print("SharedData > HTTPRequest - ERROR: Unexpected HTTP response code (\(httpResponse.statusCode))")
                    return
                }
                
                // Do something with the response
                successCallback?(data, response, error)
            } else {
                print("SharedData > HTTPRequest - ERROR: Failed to read HTTP response")
                errorCallback?(data, response, error)
            }
        }
        task.resume()
    }
}
