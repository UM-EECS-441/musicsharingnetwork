//
//  BackendAPI.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/26/20.
//

import UIKit

/**
 Interface for making calls to our backend APIs.
 */
class BackendAPI {
    static let baseURL: String = "https://backend-qjgo4vxcdq-uc.a.run.app"
    
    /**
     Attempt to login with a username and password.
     - Parameter username: username to authenticate
     - Parameter password: password to the user's account
     - Parameter successCallback: function to execute if login succeeds
     - Parameter errorCallback: function to execute if login fails
     */
    static func login(username: String, password: String, successCallback: ((String) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > login - ERROR: Failed to serialize JSON data")
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/login/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?(username)
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
}
