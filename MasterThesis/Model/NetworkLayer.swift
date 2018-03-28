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
    struct addresses {
        static var main = "http://192.168.0.31:62000/serwer/"
        static let login = "\(main)Account/MobileLogin"
        static let mobileLogOff = "\(main)Account/MobileLogOff"
        static let getAlgorithms = "\(main)MobileDevices/getAlgorithms"
        static let imageUploading = "\(main)MobileDevices/handleImageFromMobileApp"
        static let receiveImage = "\(main)MobileDevices/GetFileFromDisk"
        static let checkIfMobileAppLoggedIn = "\(main)MobileDevices/checkIfMobileAppLoggedIn"
    }
    
    func performLogin(email: String, password: String, getResponseCode: @escaping (Int) -> (Void)) {
        Alamofire.request(
            URL(string: addresses.login)!,
            method: .post,
            parameters: ["Email": email, "Password": password],
            encoding: JSONEncoding.default).response(completionHandler: { (response) in
                if let headerFiles = response.response?.allHeaderFields as? [String: String], let url = response.request?.url {
                    // saving cookies
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFiles, for: url)
                    DatabaseLayer().saveCookies(cookies: cookies)
                }
                if let statusCode = response.response?.statusCode {
                    getResponseCode(statusCode)
                }
            })
    }
    
    func checkIfMobileAppIsLoggedIn(getResponseCode: @escaping (Int) -> (Void)) {
        DatabaseLayer().loadCookies()
        Alamofire.request(
            URL(string: addresses.checkIfMobileAppLoggedIn)!,
            method: .post,
            encoding: JSONEncoding.default).response(completionHandler: { (response) in
                if let responseCode = response.response?.statusCode {
                    getResponseCode(responseCode)
                }
            })
    }
    
    func uploadImage(imageData: Data, parameters: [String: String], getResponseCode: @escaping (Int) -> (Void)) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "selectedImage", fileName: "file.jpg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: addresses.imageUploading,
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
        Alamofire.request(
            URL(string: addresses.receiveImage)!,
            method: .post,
            encoding: JSONEncoding.default).validate().responseJSON { (response) in
                if let responseCode = response.response?.statusCode {
                    if let imageData = response.data {
                        getResponseCode(responseCode, imageData)
                    }
                }
        }
    }
    
    func getAlgorithms(getAlgorithms: @escaping ([String]) -> (Void)) {
        Alamofire.request(
            URL(string: addresses.getAlgorithms)!,
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
