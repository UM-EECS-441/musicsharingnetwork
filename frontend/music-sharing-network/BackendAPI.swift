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
    
    // MARK: - Users
    
    /**
     Create a new user account.
     - Parameter username: username to claim
     - Parameter password: user's password
     - Parameter fullname: user's full name
     - Parameter bio: user's biography
     - Parameter successCallback: function to execute if account creation succeeds
     - Parameter errorCallback: function to execute if account creation fails
     */
    static func createAccount(username: String, password: String, fullname: String, bio: String, successCallback: ((String) -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build a JSON object
        let json: [String: String] = ["username": username, "password": password, "full_name": fullname, "user_bio": bio]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > createAccount - ERROR: Failed to serialize JSON data")
            errorCallback?()
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/create/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 201, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?(username)
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
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
            errorCallback?()
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
    
    /**
     Log out of the current user's account.
     - Parameter successCallback: function to execute if login succeeds
     - Parameter errorCallback: function to execute if login fails
     */
    static func logout(successCallback: (() -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/logout/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 200, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?()
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
    
    /**
     Change the current user's password.
     - Parameter old: user's old password
     - Parameter new: user's new password
     - Parameter successCallback: function to execute if password change succeeds
     - Parameter errorCallback: function to execute if password change fails
     */
    static func changePassword(old: String, new: String, successCallback: (() -> Void)? = nil, errorCallback: (() -> Void)? = nil) {
        // Serialize the username and password into JSON data
        let json: [String: String] = ["old_password": old, "new_password": new]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("BackendAPI > changePassword - ERROR: Failed to serialize JSON data")
            errorCallback?()
            return
        }
        
        // Build an HTTP request
        let requestURL = SharedData.baseURL + "/users/password/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpShouldHandleCookies = true
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send the request
        SharedData.HTTPRequest(request: request, expectedResponseCode: 204, successCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            successCallback?()
        }, errorCallback: { (data: Data?, response: URLResponse?, error: Error?) in
            errorCallback?()
        })
    }
}
