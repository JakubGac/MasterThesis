//
//  SettingsLoggedOutViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 22.04.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit

class SettingsLoggedOutViewController: UIViewController {

    @IBOutlet weak var serwerAddressTextLabel: UILabel!
    @IBOutlet weak var serwerAddressTextField: UITextField!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var checkConnectionButton: UIButton!
    
    private var networkLayer = NetworkLayer()
    
    override func viewDidLoad() {
        serwerAddressTextField.text = AddressesDao().getMainAddress()
        setButton.layer.cornerRadius = setButton.frame.size.height/2
        editButton.layer.cornerRadius = editButton.frame.size.height/2
        checkConnectionButton.layer.cornerRadius = checkConnectionButton.frame.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        serwerAddressTextField.isEnabled = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        if serwerAddressTextField.isEnabled {
            let alert = UIAlertController(title: "Uwaga!", message: "Czy na pewno chcesz zapisać?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Nie", style: .cancel) { (alert) in
                self.serwerAddressTextField.text = AddressesDao().getAddress(name: .main)
            }
            let logOffAction = UIAlertAction(title: "Tak", style: .default) { (alert) in
                self.serwerAddressTextField.isEnabled = false
                if let text = self.serwerAddressTextField.text {
                    if text.count > 0 {
                        AddressesDao().saveMainAddress(newAddress: text)
                    }
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(logOffAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            popsTheAlert(title: "", message: "Brak zmian do zapisania")
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        serwerAddressTextField.isEnabled = true
        popsTheAlert(title: "", message: "Adres dostepny do edycji")
    }
    
    @IBAction func checkConnectionButtonPressed(_ sender: UIButton) {
        popLoadingView()
        networkLayer.checkIfMobileAppIsLoggedIn { (responseCode) -> (Void) in
            if responseCode == 0 {
                self.removeLoadingView()
                self.popsTheAlert(title: "Błąd", message: "Brak połączenia z serwerem")
            } else {
                self.removeLoadingView()
                self.popsTheAlert(title: "OK", message: "Prawidłowe połączenie z serwerem")
            }
        }
    }

}
