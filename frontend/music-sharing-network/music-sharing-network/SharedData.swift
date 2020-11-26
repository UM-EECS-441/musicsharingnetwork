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
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            loginVC.completion = { (_ username: String) in
                self.username = username
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                completion?()
            }
            parentVC.present(loginVC, animated: true, completion: nil)
        } else {
            completion?()
        }
    }
    
    /**
     Send an asynchronous HTTP request and execute a block of code once the response is received.
     
     - Parameter request: the HTTP request to be sent
     - Parameter expectedResponseCode: response code that indicates a success
     - Parameter completionHandler: code to execute upon receiving a response
     */
    static func HTTPRequest(request: URLRequest, expectedResponseCode: Int, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // Check for errors
            guard let _ = data, error == nil else {
                print("SharedData > HTTPRequest - ERROR: Invalid HTTP response")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // Check for errors
                if httpResponse.statusCode != expectedResponseCode {
                    print("SharedData > HTTPRequest - ERROR: Unexpected HTTP response code (\(httpResponse.statusCode))")
                    return
                }
                
                // Do something with the response
                callback(data, response, error)
            }
        }
        task.resume()
    }
}
