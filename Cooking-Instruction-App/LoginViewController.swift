//
//  LoginViewController.swift
//  Cooking-Instruction-App
//
//  Created by Hein Thant on 11/9/2567 BE.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!  // Make sure this IBOutlet is connected in your storyboard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rounded corners for text fields and button
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 15
        
        // Enable clipping to bounds to ensure the corners are rounded
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        loginButton.clipsToBounds = true
    }

    @IBAction func loginClick(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
         
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        if !isValidEmail(email) {
            showAlert(message: "Invalid email format.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.handleLoginError(error: error)
                return
            }

            // Successfully signed in, navigate to MainTabBarController
            self.navigateToTabBarController()
        }
    }
    func handleLoginError(error: Error) {
        let nsError = error as NSError
        let errorCode = AuthErrorCode(rawValue: nsError.code)
        
        // Log the error code for debugging
        print("Login error code: \(errorCode?.rawValue ?? -1)")
        
        // Provide specific error messages based on the error code
        let errorMessage: String
        
        switch errorCode {
        case .wrongPassword:
            errorMessage = "Incorrect password. Please try again."
        case .invalidEmail:
            errorMessage = "Invalid email address. Please check and try again."
        case .userNotFound:
            errorMessage = "No user found with this email address. Please sign up."
        case .userDisabled:
            errorMessage = "This account has been disabled. Please contact support."
        case .networkError:
            errorMessage = "Network error. Please check your internet connection and try again."
        case .userTokenExpired:
            errorMessage = "Your session has expired. Please log in again."
            // Navigate to login screen
            navigateToLoginScreen()
            return
        default:
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        showAlert(message: errorMessage)
    }

     func isValidEmail(_ email: String) -> Bool {
         let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
         return emailPred.evaluate(with: email)
     }

     func showAlert(message: String) {
         let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
         let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         alertController.addAction(okAction)
         present(alertController, animated: true, completion: nil)
     }

     func navigateToTabBarController() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
             self.navigationController?.setViewControllers([tabBarController], animated: true)
         }
     }
    
    func navigateToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
 }
