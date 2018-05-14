//
//  File.swift
//  MasterThesis
//
//  Created by Jakub Gac on 22.04.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

enum addresses {
    case main
    case login
    case mobileLogOff
    case getAlgorithms
    case imageUploading
    case receiveImage
    case checkIfMobileAppLoggedIn
    case getData
    
    func name() -> String {
        switch self {
        case .main: return "main"
        case .login: return "login"
        case .mobileLogOff: return "mobileLogOff"
        case .getAlgorithms: return "getAlgorithms"
        case .imageUploading: return "imageUploading"
        case .receiveImage: return "receiveImage"
        case .checkIfMobileAppLoggedIn: return "checkIfMobileAppLoggedIn"
        case .getData: return "getData"
        }
    }
}

class Address: Object {
    @objc dynamic var name = ""
    @objc dynamic var string = ""
}

class AddressesDao {
    private var realm = try! Realm()
    
    func saveNewAddress(name: addresses, string: String) {
        if realm.objects(Address.self).filter("name contains '\(name.name())'").first == nil {
            let newAddress = Address()
            newAddress.name = name.name()
            newAddress.string = string
            
            try! realm.write {
                realm.add(newAddress)
            }
        }
    }
    
    func saveMainAddress(newAddress: String) {
        let main = realm.objects(Address.self).filter("name contains '\(addresses.main.name())'").first
        try! realm.write {
            main?.string = newAddress
        }
    }
    
    func getMainAddress() -> String {
        if let main = realm.objects(Address.self).filter("name contains '\(addresses.main.name())'").first {
            return main.string
        }
        return ""
    }
    
    func getAddress(name: addresses) -> String {
        if let main = realm.objects(Address.self).filter("name contains '\(addresses.main.name())'").first {
            if let address = realm.objects(Address.self).filter("name contains '\(name.name())'").first {
                return "\(main.string)\(address.string)"
            }
        }
        return ""
    }
}

