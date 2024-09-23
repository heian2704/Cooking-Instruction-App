import Foundation
import GoogleSignIn
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                // Check if the error is due to user cancellation
                if let nsError = error as NSError?, nsError.code == -5 {
                    print("User canceled the Google sign-in flow.")  // Log for debugging
                    completion(.failure(NSError(domain: "GoogleSignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "User canceled the sign-in flow."])))
                } else {
                    // Log other errors to understand what went wrong
                    print("Error during Google sign-in: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                return
            }
            
            guard let user = result?.user else {
                let userError = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])
                completion(.failure(userError))
                return
            }
            
            // Access the idToken and accessToken directly
            if let idToken = user.idToken?.tokenString {
                let accessToken = user.accessToken.tokenString
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let email = authResult?.user.email
                        if let email = email {
                            completion(.success(email))
                        } else {
                            let emailError = NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not found in auth result."])
                            completion(.failure(emailError))
                        }
                    }
                }
            } else {
                let tokenError = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error retrieving id token."])
                completion(.failure(tokenError))
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google if the user is signed in
            if GIDSignIn.sharedInstance.currentUser != nil {
                GIDSignIn.sharedInstance.signOut()
            }
            
            // Reset the UI or navigate back to the login screen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.resetToLoginScreen()
            }
            
            completion(.success(()))
            
        } catch let signOutError {
            completion(.failure(signOutError))
        }
    }
}
