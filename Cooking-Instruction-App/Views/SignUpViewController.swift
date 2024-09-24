import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailbtn: UIButton!
    @IBOutlet weak var passwordbtn: UIButton!

    private var viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        signUpButton.isHidden = false
        signUpButton.alpha = 1.0
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        signUpButton.clipsToBounds = true
        let envelopeImage = UIImage(systemName: "envelope")
        emailbtn.setImage(envelopeImage, for: .normal)
        emailbtn.tintColor = UIColor.systemBlue
        let lockImage = UIImage(systemName: "lock")
        passwordbtn.setImage(lockImage, for: .normal)
        passwordbtn.tintColor = UIColor.systemBlue
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        viewModel.email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.signUp { result in
            switch result {
            case .success:
                self.showSuccessAlert()
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You have successfully signed up.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Reset to IconAppViewController instead of popping
            self.resetToIconAppViewController()
        })
        present(alert, animated: true, completion: nil)
    }
    
    private func resetToIconAppViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let iconAppViewController = storyboard.instantiateViewController(withIdentifier: "IconAppViewController")
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = iconAppViewController
            sceneDelegate.window?.makeKeyAndVisible()
            
            // Optionally animate the transition
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
