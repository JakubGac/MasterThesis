//
//  LoginViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 12.11.2017.
//  Copyright © 2017 Jakub Gac. All rights reserved.
//

import UIKit
import SystemConfiguration

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    // temporary variables
    private var username = "user@poczta.pl"
    private var password = "test"
    
    override func viewDidLoad() {
        let height = UIScreen.main.bounds.height / 22
        let width = UIScreen.main.bounds.width * 0.8
        loginTextField.frame.size = CGSize(width: width, height: height)
        passwordTextField.frame.size = CGSize(width: width, height: height)
        passwordTextField.isSecureTextEntry = true
        signInButton.frame.size = CGSize(width: width/2, height: height)
        signInButton.layer.cornerRadius = height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // popracować tutaj nad mechanizmem sprawdznia dostepu do internetu
        if !Reachability.isConnectedToNetwork() {
            popsTheAlert(title: "Brak dostepu do internetu", message: "Polaczenie jest wymagane do dzialania aplikacji")
        }
    }
    
    @IBAction func signInButtonTouched(_ sender: UIButton) {
        if loginTextField.text == "" {
            popsTheAlert(title: "Brak loginu", message: "")
        } else {
            if passwordTextField.text == "" {
                popsTheAlert(title: "Brak hasła", message: "")
            } else {
                print("Wszystko okej")
            }
        }
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
    func popsTheAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
