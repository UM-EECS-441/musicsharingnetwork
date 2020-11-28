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
    static var username: String = ""
    static var logged_in: Bool {
        get {
            !self.username.isEmpty
        }
    }
    
    /**
     If the user is not logged in, prompt them to log in.
     
     - Parameter parentVC: the view controller requesting the user to log in
     - Parameter completion: closure to run after the user logs in
     */
    static func login(parentVC: UIViewController, completion: (() -> Void)?) {
        if self.username == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let loginNavController = storyBoard.instantiateViewController(withIdentifier: "LoginNavigationController")
            parentVC.present(loginNavController, animated: true, completion: nil)
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
