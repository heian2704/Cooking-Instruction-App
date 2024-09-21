//
//  IconAppViewController.swift
//  Cooking-Instruction-App
//
//  Created by Hein Thant on 11/9/2567 BE.
//

import UIKit

class IconAppViewController: UIViewController {
    
    // IBOutlet connections for buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton! // IBOutlet for Google Sign-In button
    
    // IBOutlet connections for images and labels
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    private var authService = AuthService.shared  // Accessing the singleton

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the corner radius for buttons
        loginButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        googleSignInButton.layer.cornerRadius = 10 // Set corner radius for Google Sign-In button
        
        // Enable clipping to bounds to ensure the corners are rounded
        loginButton.clipsToBounds = true
        signUpButton.clipsToBounds = true
        googleSignInButton.clipsToBounds = true
        
        // Set images for UIImageViews
        firstImageView.image = UIImage(named: "Cooking-Craft")
        secondImageView.image = UIImage(named: "Cooking-Craft-withlogo")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController?.pushViewController(loginVC, animated: true)
        } else {
            print("Error: Could not instantiate LoginViewController.")
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpVC, animated: true)
        } else {
            print("Error: Could not instantiate SignUpViewController.")
        }
    }
    
    @IBAction func googleSignInTapped(_ sender: UIButton) {
        AuthService.shared.signInWithGoogle(presenting: self) { result in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                switch result {
                case .success(let email):
                    print("User signed in: \(email)")
                    self.navigateToTabBarController()
                case .failure(let error):
                    // Check for specific error cases
                    if error.localizedDescription == "User canceled the sign-in flow." {
                        print("Google sign-in was canceled.")
                    } else {
                        print("Error signing in: \(error.localizedDescription)")
                    }
                }
            }
        }
    }


    
    private func navigateToTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            self.navigationController?.setViewControllers([tabBarController], animated: true)
        }
    }
}
