import Foundation
import FirebaseAuth

class SignUpViewModel {
    var email: String?
    var password: String?
    
    func signUp(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let email = email, let password = password else {
            completion(.failure(NSError(domain: "SignUpViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email and Password cannot be empty"])))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}
