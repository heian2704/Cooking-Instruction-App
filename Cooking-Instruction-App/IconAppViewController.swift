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
    
    // IBOutlet connections for images and labels
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the corner radius for buttons
        loginButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        
        // Enable clipping to bounds to ensure the corners are rounded
        loginButton.clipsToBounds = true
        signUpButton.clipsToBounds = true
        
        // Set images for UIImageViews
        firstImageView.image = UIImage(named: "Cooking-Craft")
        secondImageView.image = UIImage(named: "Cooking-Craft-withlogo")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
}
