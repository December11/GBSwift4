//
//  ViewController.swift
//  weatherApp
//
//  Created by Alla Shkolnik on 15.12.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var stackBottomConstraint: NSLayoutConstraint!
    @IBAction func loginButton(_ sender: UIButton) {
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.stackBottomConstraint.constant = 200
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.stackBottomConstraint.constant = 20
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    //MARK: - Keyboard (hide)
    @IBAction func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Private methods
    private func checkUser(correctUsername: String = "admin", correctPassword: String = "12345") -> Bool {
        loginTextField.text == correctUsername && passwordTextField.text == correctPassword
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "goToMain":
            if !checkUser(correctUsername: "", correctPassword: "") {
                presentAlert()
                return false
            } else {
                clearData()
                return true
            }
        default:
            return false
        }
    }
    
    private func presentAlert() {
        let alertController = UIAlertController(
            title: "Error", message: "Incorrect username of password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .cancel)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func clearData() {
        loginTextField.text = ""
        passwordTextField.text = ""
    }


}

