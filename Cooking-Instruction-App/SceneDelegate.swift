import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create a new UIWindow using the windowScene
        window = UIWindow(windowScene: windowScene)

        // Check if the user is logged in
        if Auth.auth().currentUser != nil {
            // User is logged in, set the root view controller to MainTabBarController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            window?.rootViewController = mainTabBarController
        } else {
            // User is not logged in, set the root view controller to IconAppViewController (login/initial screen)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let iconAppViewController = storyboard.instantiateViewController(withIdentifier: "IconAppViewController")
            window?.rootViewController = iconAppViewController
        }

        // Make the window visible
        window?.makeKeyAndVisible()
    }

    // Handle the user logging out by resetting the root view controller
    func resetToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let iconAppViewController = storyboard.instantiateViewController(withIdentifier: "IconAppViewController")
        
        // Set the root view controller to the login screen and animate the transition
        window?.rootViewController = iconAppViewController
    }

    // Other lifecycle methods as needed
}
