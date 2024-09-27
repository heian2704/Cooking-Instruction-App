import UIKit
import SDWebImage
import UserNotifications

class RecipeDetailViewController: UIViewController {

    var recipe: Recipe?  // The property to hold the selected recipe
    var isLocalRecipe: Bool = false  // Flag to indicate if the recipe is local
    private var hasShownNotification = false // Flag to prevent multiple notifications

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView! // Outlet for progress view
    @IBOutlet weak var startTimerButton: UIButton! // Outlet for timer button

    // Timer properties
    var timer: Timer?
    var totalCookingTime: Int = 10 // Total cooking time in seconds
    var elapsedTime: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            }
        }

        // If the recipe is local, don't fetch details from the API
        if isLocalRecipe {
            setupLocalRecipeDetails()  // Directly set the recipe details if it is a local recipe
        } else if let recipe = recipe {
            fetchRecipeDetails(recipeId: recipe.id)  // Fetch from the API for non-local recipes
        }

        // Configure progress view
        progressView.tintColor = UIColor.yellow // Consumed time color
        progressView.trackTintColor = UIColor.lightGray // Remaining time color
        progressView.progress = 0.0 // Start with an empty progress view
    
        imageView.layer.cornerRadius = 20
        startTimerButton.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }

    // MARK: - Fetch Recipe Details (API-based recipes)
    private func fetchRecipeDetails(recipeId: Int) {
        let viewModel = RecipeDetailViewModel()
        viewModel.fetchRecipeDetails(by: recipeId) { [weak self] detailedRecipe in
            guard let self = self, let detailedRecipe = detailedRecipe else {
                return
            }
            // Set up UI with detailed recipe info
            self.recipe = detailedRecipe
            self.setupRecipeDetails()
        }
    }

    // MARK: - Setup Methods
    // This method will handle displaying details for API-based recipes
    private func setupRecipeDetails() {
        guard let recipe = recipe else { return }

        // Set title
        titleLabel.text = recipe.title

        // Handle local image or load from web URL
        if let localImagePath = recipe.imagePath, FileManager.default.fileExists(atPath: localImagePath) {
            // Load local image from path
            imageView.image = UIImage(contentsOfFile: localImagePath)
        } else if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
            // Load image from web URL
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            // Default placeholder
            imageView.image = UIImage(named: "placeholder")
        }

        // Set ingredients
        if let ingredients = recipe.ingredients?.map({ $0.name }) {
            ingredientsLabel.text = ingredients.joined(separator: ", ")
        } else {
            ingredientsLabel.text = "No ingredients available"
        }

        // Set cooking time
        if let cookingTime = recipe.cookingTime {
            cookingTimeLabel.text = "\(cookingTime) min"
        } else {
            cookingTimeLabel.text = "Cooking Time: N/A"
        }

        // Display rating if available
        if let rating = recipe.rating {
            ratingLabel.text = "Rating: \(rating)/5"
        } else {
            ratingLabel.text = "Rating: N/A"
        }

        // Update favorite button appearance
        updateFavoriteButton()
    }

    private func setupLocalRecipeDetails() {
        guard let recipe = recipe else {
            print("Recipe object is nil.")
            return
        }

        // Set title and log it
        titleLabel.text = recipe.title
        print("Recipe title: \(recipe.title)")
        
        if let imagePath = recipe.image, FileManager.default.fileExists(atPath: imagePath) {
            let localImage = UIImage(contentsOfFile: imagePath)
            imageView.image = localImage ?? UIImage(named: "placeholder")
        } else {
            imageView.image = UIImage(named: "placeholder")
        }

        // Set ingredients and log them
        if let ingredients = recipe.ingredients?.map({ $0.name }) {
            ingredientsLabel.text = ingredients.joined(separator: ", ")
            print("Ingredients: \(ingredients.joined(separator: ", "))")
        } else {
            ingredientsLabel.text = "No ingredients available"
            print("No ingredients available")
        }

        // Set cooking time
        if let cookingTime = recipe.cookingTime {
            cookingTimeLabel.text = "\(cookingTime) min"
        } else {
            cookingTimeLabel.text = "Cooking Time: N/A"
        }

        // Set rating
        if let rating = recipe.rating {
            ratingLabel.text = "Rating: \(rating)/5"
        } else {
            ratingLabel.text = "Rating: N/A"
        }
    }

    // MARK: - Favorite Button Actions
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        toggleFavoriteStatus()
    }

    private func updateFavoriteButton() {
        guard let recipe = recipe else { return }

        let isFavorite = FavoriteRecipesManager.shared.isFavorite(recipe)
        let heartImage = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
    }

    private func toggleFavoriteStatus() {
        guard let recipe = recipe else { return }

        if FavoriteRecipesManager.shared.isFavorite(recipe) {
            FavoriteRecipesManager.shared.remove(recipe)
        } else {
            FavoriteRecipesManager.shared.add(recipe)
        }

        updateFavoriteButton()
    }

    // MARK: - Timer Functionality
    @IBAction func startTimerButtonTapped(_ sender: UIButton) {
        startTimer()
    }

    private func startTimer() {
        elapsedTime = 0
        hasShownNotification = false // Reset notification flag for the new timer

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        progressView.progress = 0.0 // Reset progress view
    }

    @objc private func updateTimer() {
        if elapsedTime >= totalCookingTime {
            timer?.invalidate()
            timer = nil
            showCompletionNotification()
            return
        }

        elapsedTime += 1
        let progress = Float(elapsedTime) / Float(totalCookingTime)
        
        // Smooth animation for progress view
        UIView.animate(withDuration: 1.0) {
              self.progressView.setProgress(progress, animated: true)
          }

        // Update button title with remaining time in minutes
        let remainingTime = totalCookingTime - elapsedTime
        let remainingSeconds = remainingTime % 60
        startTimerButton.setTitle("\(remainingSeconds)", for: .normal)
    }

    // Show completion notification when the cooking timer finishes
    private func showCompletionNotification() {
        if !hasShownNotification {
            hasShownNotification = true
                
            UIView.animate(withDuration: 1.0) {
                self.startTimerButton.backgroundColor = UIColor.green
                self.progressView.tintColor = UIColor.green
            }
                
            let alert = UIAlertController(title: "Cooking Complete", message: "Your dish is ready!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            sendLocalNotification()
        }
        animateButtonPulsing()
    }

    // Local notification setup for completion
    private func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Cooking Complete"
        content.body = "Your dish is ready to serve!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Button Actions for Details and Recipe
    @IBAction func detailsButtonTapped(_ sender: UIButton) {
        guard let recipe = recipe else { return }

        var details = "Title: \(recipe.title)\n\n"
        if let ingredients = recipe.ingredients?.map({ $0.name }) {
            details += "Ingredients: \(ingredients.joined(separator: ", "))\n\n"
        }
        if let cookingTime = recipe.cookingTime {
            details += "Cooking Time: \(cookingTime) min\n\n" // Show cooking time in minutes
        }
        if let rating = recipe.rating {
            details += "Rating: \(Int(rating))/5"
        }

        // Present details in an alert or a new view
        let alert = UIAlertController(title: "Recipe Details", message: details, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func animateButtonPulsing() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity

        startTimerButton.layer.add(pulseAnimation, forKey: "pulsing")
    }
}
