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
    static let baseURL: String = "https://backend-qjgo4vxcdq-uc.a.run.app"
    static var username: String = ""
    static var logged_in: Bool {
        get {
            !self.username.isEmpty
        }
    }
    static let spotifyClientID: String = "c0a5c9b2c5b94d00b5599dd76b092414"
    static let spotifyClientSecret: String = "225ff590d76d4d6db2168af29e627dd4"
    static let spotifyCallbackURI: String = "music-sharing-network://spotify-login-callback"
    
    static var appDelegate: AppDelegate {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("SharedData > appDelegate: ERROR - Unable to get app delegate")
            }
            return appDelegate
        }
    }
    
    /*
     Send an HTTP request and wait for the response.
     */
    static func SynchronousHTTPRequest(_ request: URLRequest,  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let sem = DispatchSemaphore.init(value: 0)
        
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let task = URLSession.shared.dataTask(with: request) {(_data, _response, _error) in
            data = _data
            response = _response
            error = _error
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        completionHandler(data, response, error)
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
