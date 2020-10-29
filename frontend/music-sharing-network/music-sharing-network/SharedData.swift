//
//  SharedData.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 10/28/20.
//

import UIKit

class SharedData {
    static let baseURL: String = "https://backend-qjgo4vxcdq-uc.a.run.app"
    static var cookie: HTTPCookie? = nil
    
    static func getCoookie() -> HTTPCookie? {
        return self.cookie
    }
    
    static func setCookie(_ httpResponse: HTTPURLResponse) {
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String], for: httpResponse.url!)
        self.cookie = cookies[0]
    }
}
