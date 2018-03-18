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
    private let realm = try! Realm()
    
    class LoggedInPerson: Object {
        @objc dynamic var cookie = [HTTPCookie]()
    }
    
    func saveCookie(cookie: [HTTPCookie]) {
        if let loggedInPerson = realm.objects(LoggedInPerson.self).first {
            loggedInPerson.cookie = cookie
        } else {
            let newLoggedInPerson = LoggedInPerson()
            newLoggedInPerson.cookie = cookie
            try! realm.write {
                realm.add(newLoggedInPerson)
            }
        }
    }
    
    func checkCookie() {
        if let loggedInPerson = realm.objects(LoggedInPerson.self).first {
            print(loggedInPerson.cookie)
        } else {
            print("Brak cookie zapisanego w bazie")
        }
    }
}
