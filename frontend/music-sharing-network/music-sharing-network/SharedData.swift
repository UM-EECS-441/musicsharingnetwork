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
    
    /*
     Send an HTTP request and wait for the response.
     */
    static func SynchronousHTTPRequest(_ request: URLRequest) -> (Data?, URLResponse?, Error?) {
        let sem = DispatchSemaphore.init(value: 0)
        
        var result: (Data?, URLResponse?, Error?)
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            result = (data, response, error)
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        return result
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
                completion?()
            }
            parentVC.navigationController?.show(loginVC, sender: nil)
        } else {
            completion?()
        }
    }
    
}
