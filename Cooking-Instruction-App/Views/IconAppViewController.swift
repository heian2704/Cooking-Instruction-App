import UIKit
import GoogleSignIn

class IconAppViewController: UIViewController {
    
    // IBOutlet connections for buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // IBOutlet connections for images and labels
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var googleSignInButton: UIButton!
    private var authService = AuthService.shared  // Accessing the singleton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the corner radius for buttons
        loginButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10// Set corner radius for Google Sign-In button
        googleSignInButton.layer.cornerRadius = 10 
        // Enable clipping to bounds to ensure the corners are rounded
        loginButton.clipsToBounds = true
        signUpButton.clipsToBounds = true
        googleSignInButton.clipsToBounds = true
        
        // Set images for UIImageView
        secondImageView.image = UIImage(named: "Cooking-Craft-withlogo")
        googleSignInButton.isHidden = false
        googleSignInButton.tintColor = .blue
        googleSignInButton.setImage(UIImage(named: "google"), for: .normal)
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
                DispatchQueue.main.async {
                    switch result {
                    case .success(let email):
                        print("User signed in: \(email)")
                        self.navigateToTabBarController()
                    case .failure(let error):
                        // Only show an error for non-cancellation issues
                        if !(error.localizedDescription.contains("User canceled the sign-in flow.")) {
                        }
                    }
                }
            }
        }

    
    private func navigateToTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            // Set the root view controller instead of using navigationController
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
}
