//
//  ViewController.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import UIKit

class  LoginViewController: UIViewController ,UITextViewDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    private func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            self.showAlert(title: "warning", message: ("Please enter e-mail and password"))
            
        }
        if !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
            API.postSession(username: emailTextField.text!, password: passwordTextField.text!) { (errString) in
                guard errString == nil else {
                    self.showAlert(title: "Error", message: errString!)
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "Login", sender: nil)
                }
                
            }
        }
    }
}
