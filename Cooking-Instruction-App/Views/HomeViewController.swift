import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIButton! // IBOutlet for the button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Optional: Customize the button title if needed
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            // Firebase sign-out
            try Auth.auth().signOut()

            // Check if the user is signed in with Google
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.signOut() // Google sign-out
            }

            // Navigate back to the IconAppViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let iconAppViewController = storyboard.instantiateViewController(withIdentifier: "IconAppViewController") as! IconAppViewController
            
            // Set the root view controller to the IconAppViewController
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UINavigationController(rootViewController: iconAppViewController)
                window.makeKeyAndVisible()
            }

        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

}
