//
//  DatabaseLayer.swift
//  MasterThesis
//
//  Created by Jakub Gac on 16.03.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class DatabaseLayer {
    func saveCookies(cookies: [HTTPCookie]) {
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        UserDefaults.standard.set(cookieArray, forKey: "savedCookie")
        UserDefaults.standard.synchronize()
    }
    
    func loadCookies() {
        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookie") as? [[HTTPCookiePropertyKey: Any]] else {
            return
        }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    func deleteCookies() {
        UserDefaults.standard.removeObject(forKey: "savedCookie")
    }
}
