//
//  NetworkLayer.swift
//  MasterThesis
//
//  Created by Jakub Gac on 16.03.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import Alamofire

class NetworkLayer {
    let sessionManager: Alamofire.SessionManager
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5.0
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func performLogin(email: String, password: String, getResponseCode: @escaping (Int) -> (Void)) {
        let address = AddressesDao().getAddress(name: .login)
        sessionManager.request(
            URL(string: address)!,
            method: .post,
            parameters: ["Email": email, "Password": password],
            encoding: JSONEncoding.default).responseData { (response) in
                switch response.result {
                case .success:
                    if let headerFiles = response.response?.allHeaderFields as? [String: String], let url = response.request?.url {
                        // saving cookies
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFiles, for: url)
                        DatabaseLayer().saveCookies(cookies: cookies)
                    }
                    if let statusCode = response.response?.statusCode {
                        getResponseCode(statusCode)
                    }
                case .failure:
                    getResponseCode(0)
                }
        }
    }
    
    func checkIfMobileAppIsLoggedIn(getResponseCode: @escaping (Int) -> (Void)) {
        DatabaseLayer().loadCookies()
        let address = AddressesDao().getAddress(name: .checkIfMobileAppLoggedIn)
        sessionManager.request(
            URL(string: address)!,
            method: .post,
            encoding: JSONEncoding.default).responseData { (response) in
                switch response.result {
                case .success:
                    if let responseCode = response.response?.statusCode {
                        getResponseCode(responseCode)
                    }
                    break
                case .failure:
                    getResponseCode(0)
                    break
                }
        }
    }
    
    func uploadImage(imageData: Data, parameters: [String: String], getResponseCode: @escaping (Int) -> (Void)) {
        let address = AddressesDao().getAddress(name: .imageUploading)
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "selectedImage", fileName: "file.jpg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: address,
           encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                //upload.uploadProgress(closure: { (progress) in
                //    print("Upload Progress: \(progress.fractionCompleted)")
                //})
                upload.responseJSON { response in
                    if let code = response.response?.statusCode {
                        getResponseCode(code)
                    }
                }
            case .failure:
                getResponseCode(403)
            }
        })
    }
    
    func downloadImage(getResponseCode: @escaping (Int, Data) -> (Void)) {
        let address = AddressesDao().getAddress(name: .receiveImage)
        sessionManager.request(
            URL(string: address)!,
            method: .post,
            encoding: JSONEncoding.default).validate().responseJSON { (response) in
                if let responseCode = response.response?.statusCode {
                    if let imageData = response.data {
                        getResponseCode(responseCode, imageData)
                    }
                }
        }
    }
    
    func getData(getDataFromProcessing: @escaping ([String]) -> (Void)) {
        let address = AddressesDao().getAddress(name: .getData)
        sessionManager.request(
            URL(string: address)!,
            method: .post,
            encoding: JSONEncoding.default).validate().responseJSON { (response) in
                if let values = response.result.value {
                    if let json = values as? NSDictionary {
                        //var arrayOfElements: [String] = []
                        for (key, value) in json {
                            if let key_to_element = key as? String {
                                switch key_to_element {
                                case "totalAmount":
                                    print("calkowita liczba elementow: \(value)")
                                case "data":
                                    print("wartosci: \(value)")
                                default:
                                    break
                                }
                            }
                        }
                        //print(arrayOfElements)
                    }
                }
                /*if let values = response.result.value {
                    if let json = values as? NSDictionary {
                        var arrayOfElements: [String] = []
                        for (_, value) in json {
                            if let tmp = value as? String {
                                arrayOfElements.append(tmp)
                            }
                        }
                        getDataFromProcessing(arrayOfElements)
                    }
                }*/
        }
    }
    
    func getAlgorithms(getAlgorithms: @escaping ([String]) -> (Void)) {
        let address = AddressesDao().getAddress(name: .getAlgorithms)
        sessionManager.request(
            URL(string: address)!,
            method: .post,
            encoding: JSONEncoding.default).validate().responseJSON { (response) in
                if let values = response.result.value {
                    if let json = values as? NSDictionary {
                        var arrayOfElements: [String] = []
                        for (_, value) in json {
                            if let tmp = value as? String {
                                arrayOfElements.append(tmp)
                            }
                        }
                        getAlgorithms(arrayOfElements)
                    }
                }
        }
    }
}
