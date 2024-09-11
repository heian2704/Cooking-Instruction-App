//
//  EditProfileViewController.swift
//  Cooking-Instruction-App
//
//  Created by Hein Thant on 11/9/2567 BE.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
    }
    func loadUserProfile() {
        guard let user = Auth.auth().currentUser else {
            showAlert(message: "No user is logged in")
            return
        }
        emailTextField.text = user.email
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {
            showAlert(message: "No user is logged in")
            navigateToLoginScreen()
            return
        }
        
        let currentPassword = currentPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !newPassword.isEmpty {
            if newPassword == confirmPassword {
                // Re-authenticate user before updating password
                let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
                user.reauthenticate(with: credential) { [weak self] result, error in
                    if let error = error {
                        self?.showAlert(message: "Re-authentication failed: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update the password
                    user.updatePassword(to: newPassword) { [weak self] error in
                        if let error = error {
                            self?.showAlert(message: "Error updating password: \(error.localizedDescription)")
                        } else {
                            self?.showAlert(message: "Password updated successfully.")
                        }
                    }
                }
            } else {
                self.showAlert(message: "Passwords do not match")
            }
        } else {
            self.showAlert(message: "Please enter a new password")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController?.setViewControllers([loginVC], animated: true)
        }
    }
}
