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
    @IBOutlet weak var signUpButton: UIButton!  // Make sure this IBOutlet is connected to the button in the storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rounded corners for text fields
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        confirmPasswordTextField.layer.cornerRadius = 10
        
        // Enable clipping to bounds to ensure the corners are rounded
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        confirmPasswordTextField.clipsToBounds = true
        
        // Rounded corners for the Sign Up button
        signUpButton.layer.cornerRadius = 10
        signUpButton.clipsToBounds = true
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

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
