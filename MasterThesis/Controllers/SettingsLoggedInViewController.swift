//
//  SettingsViewController.swift
//  MasterThesis
//
//  Created by Jakub Gac on 27.03.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit

class SettingsLoggedInViewController: UIViewController {

    @IBOutlet weak var logOffButton: UIButton!
    @IBOutlet weak var serwerAddressTextLabel: UILabel!
    @IBOutlet weak var serwerAddressTextField: UITextField!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var checkConnectionButton: UIButton!
    
    private var networkLayer = NetworkLayer()
    
    override func viewDidLoad() {
        serwerAddressTextField.text = AddressesDao().getMainAddress()
        logOffButton.layer.cornerRadius = logOffButton.frame.size.height/2
        setButton.layer.cornerRadius = setButton.frame.size.height/2
        editButton.layer.cornerRadius = editButton.frame.size.height/2
        checkConnectionButton.layer.cornerRadius = checkConnectionButton.frame.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        serwerAddressTextField.isEnabled = false
    }
    
    @IBAction func logOffButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Uwaga!", message: "Czy na pewno chcesz się wylogować?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
        let logOffAction = UIAlertAction(title: "Tak", style: .default) { (alert) in
            DatabaseLayer().deleteCookies()
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.view.removeFromSuperview()
        }
        alert.addAction(cancelAction)
        alert.addAction(logOffAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        if serwerAddressTextField.isEnabled {
            let alert = UIAlertController(title: "Uwaga!", message: "Czy na pewno chcesz zapisać? Zapisanie nowego adresu spowoduje automatyczne wylogowanie użytkownika.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Nie", style: .cancel) { (alert) in
                self.serwerAddressTextField.text = AddressesDao().getMainAddress()
            }
            let logOffAction = UIAlertAction(title: "Tak", style: .default) { (alert) in
                self.serwerAddressTextField.isEnabled = false
                if let text = self.serwerAddressTextField.text {
                    if text.count > 0 {
                        AddressesDao().saveMainAddress(newAddress: text)
                        DatabaseLayer().deleteCookies()
                        self.navigationController?.popViewController(animated: true)
                        self.tabBarController?.view.removeFromSuperview()
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
        popsTheAlert(title: "", message: "Adres dostepny do edycji. ")
    }
    
    @IBAction func checkConnectionButtonPressed(_ sender: UIButton) {
        // ta funkcja do poprawy bo metoda sprawdza po ciasteczkach
        networkLayer.checkIfMobileAppIsLoggedIn { (responseCode) -> (Void) in
            if responseCode == 200 || responseCode == 403 {
                self.popsTheAlert(title: "OK", message: "Prawidłowe połączenie z serwerem")
            } else {
                self.popsTheAlert(title: "Błąd", message: "Brak połączenia z serwerem")
            }
        }
    }
}
