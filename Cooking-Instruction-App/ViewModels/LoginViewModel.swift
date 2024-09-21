import Foundation
import FirebaseAuth

class LoginViewModel {
    var email: String?
    var password: String?

    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let email = email, let password = password else {
            completion(.failure(NSError(domain: "LoginViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email and Password cannot be empty"])))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}
