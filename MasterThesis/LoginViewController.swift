//
//  LoginViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 12.11.2017.
//  Copyright © 2017 Jakub Gac. All rights reserved.
//

import UIKit
import SystemConfiguration
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        let height = UIScreen.main.bounds.height / 22
        let width = UIScreen.main.bounds.width * 0.8
        loginTextField.frame.size = CGSize(width: width, height: height)
        passwordTextField.frame.size = CGSize(width: width, height: height)
        passwordTextField.isSecureTextEntry = true
        signInButton.frame.size = CGSize(width: width/2, height: height)
        signInButton.layer.cornerRadius = height / 2
        continueButton.frame.size = CGSize(width: width/2, height: height)
        continueButton.layer.cornerRadius = height / 2
        
        signInButton.isUserInteractionEnabled = true
        signInButton.isEnabled = true
        loginTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        continueButton.isHidden = true
        NetworkLayer().checkIfMobileAppIsLoggedIn { (responseCode) -> (Void) in
            if responseCode == 200 {
                self.continueButton.isHidden = false
            } else {
                self.continueButton.isHidden = true
            }
        }
        //DatabaseLayer().checkCookie()
        print("wywolane")
        NetworkLayer().checkIfMobileAppIsLoggedIn { (responseCode) -> (Void) in
            print("poczatek")
            print(responseCode)
            print("koniec")
        }
        print("zakończone")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // popracować tutaj nad mechanizmem sprawdznia dostepu do internetu
        if !Reachability.isConnectedToNetwork() {
            popsTheAlert(title: "Brak dostepu do internetu", message: "Polaczenie jest wymagane do dzialania aplikacji")
        }
    }
    
    @IBAction func signInButtonTouched(_ sender: UIButton) {
        if let login = loginTextField.text {
            if let password = passwordTextField.text {
                if password.count > 5 {
                    signInButton.isUserInteractionEnabled = false
                    loginTextField.isEnabled = false
                    passwordTextField.isEnabled = false
                    popLoadingView()
                    
                    NetworkLayer().performLogin(email: login, password: password, getResponseCode: { (responseCode) -> (Void) in
                        switch responseCode {
                        case 200:
                            self.removeLoadingView()
                            self.performSegue(withIdentifier: "TakingImage", sender: nil)
                        case 403:
                            self.popsTheAlert(title: "Błąd", message: "Rozpoznaje twój email ale coś poszło nie tak")
                        case 404:
                            self.popsTheAlert(title: "Błąd", message: "Brak konta przypisanego do podanego emaila")
                        default:
                            self.popsTheAlert(title: "Błąd", message: "Spróbuj ponownie")
                        }
                        self.removeLoadingView()
                        self.signInButton.isUserInteractionEnabled = true
                        self.loginTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    })
                } else {
                    popsTheAlert(title: "Błąd", message: "Hasło zbyt krótkie")
                }
            }
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "TakingImage", sender: nil)
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}

extension UIViewController {
    struct serverAddresses {
        static let mainAddress = "http://192.168.0.21:62000/serwer/"
        static let loginAddress = "\(mainAddress)Account/MobileLogin"
        static let getAlgorithmsAddress = "\(mainAddress)MobileDevices/getAlgorithms"
        static let imageUploading = "\(mainAddress)MobileDevices/handleImageFromMobileApp"
        static let receiveImage = "\(mainAddress)MobileDevices/GetFileFromDisk"
        static let checkIfMobileAppLoggedIn = "\(mainAddress)MobileDevices/checkIfMobileAppLoggedIn"
    }
    
    func popsTheAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func popLoadingView() {
        let activityIndicatorView = UIView();
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width/4, height: self.view.bounds.width/4)
        activityIndicatorView.backgroundColor = UIColor.black
        activityIndicatorView.center = self.view.center
        activityIndicatorView.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        activityIndicatorView.layer.cornerRadius = activityIndicatorView.layer.bounds.width/8
        activityIndicatorView.tag = 1001
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: activityIndicatorView.bounds.width/4, y: activityIndicatorView.bounds.height/4, width: activityIndicatorView.bounds.width/2, height: activityIndicatorView.bounds.width/2))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        activityIndicatorView.addSubview(activityIndicator)
        self.view.addSubview(activityIndicatorView)
    }
    
    func removeLoadingView() {
        if let viewToRemove = self.view.viewWithTag(1001) {
            viewToRemove.removeFromSuperview()
        }
    }
}
