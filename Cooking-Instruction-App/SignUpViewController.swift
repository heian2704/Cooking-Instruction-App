//
//  SignUpViewController.swift
//  Cooking-Instruction-App
//
//  Created by Hein Thant on 11/9/2567 BE.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
      
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
@IBAction func SignUpClick(_ sender: Any) {
    guard let email = emailTextField.text else {return}
    guard let password = passwordTextField.text else {return}
    guard let confirmPassword = confirmPasswordTextField.text else { return }

        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
                return
        }
    Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                self.showAlert(message: "Error creating user: \(error.localizedDescription)")
                return
            }
            self.showSuccessAlert()
        }
    }

    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You have successfully signed up.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate back after the alert is dismissed
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true, completion: nil)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        }
    }
