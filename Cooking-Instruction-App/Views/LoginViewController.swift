import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 15
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        loginButton.clipsToBounds = true
    }
    
    @IBAction func loginClick(_ sender: Any) {
        viewModel.email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.login { result in
            switch result {
            case .success:
                self.navigateToTabBarController()
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
