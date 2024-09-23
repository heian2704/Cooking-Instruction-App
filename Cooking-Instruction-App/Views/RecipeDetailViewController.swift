import UIKit
import SDWebImage
import UserNotifications

class RecipeDetailViewController: UIViewController {

    var recipe: Recipe?  // The property to hold the selected recipe
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
    var totalCookingTime: Int = 0 // Total cooking time in seconds
    var elapsedTime: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            }
        }

        // Fetch recipe details and cooking time from API
        if let recipe = recipe {
            fetchRecipeDetails(recipeId: recipe.id)
        }

        // Configure progress view
        progressView.tintColor = UIColor.blue // Consumed time color
        progressView.trackTintColor = UIColor.lightGray // Remaining time color
        progressView.progress = 0.0 // Start with an empty progress view
    }

    // MARK: - Fetch Recipe Details
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
    private func setupRecipeDetails() {
        guard let recipe = recipe else { return }

        // Set title and image
        titleLabel.text = recipe.title
        if let imageUrl = URL(string: recipe.image) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }

        // Set ingredients
        if let ingredients = recipe.ingredients?.map({ $0.name }) {
            ingredientsLabel.text = ingredients.joined(separator: ", ")
        } else {
            ingredientsLabel.text = "No ingredients available"
        }

        // **Get cooking time from API** and display based on its value
        let cookingTimeInMinutes = recipe.cookingTime ?? 1
        totalCookingTime = 30 // Set timer to (30 seconds) for testing

        if cookingTimeInMinutes >= 60 {
            let cookingTimeInHours = cookingTimeInMinutes / 60
            cookingTimeLabel.text = "\(cookingTimeInHours) hr"
            startTimerButton.setTitle("\(cookingTimeInHours) hr", for: .normal) // Show 1 hour if time is 1 hour or more
        } else {
            cookingTimeLabel.text = "\(cookingTimeInMinutes) min"
            startTimerButton.setTitle("\(cookingTimeInMinutes) min", for: .normal) // Show minutes if time is less than 1 hour
        }

        // Display rating
        ratingLabel.text = recipe.rating != nil ? "\(recipe.rating!)/5" : "N/A"

        // Update the favorite button appearance
        updateFavoriteButton()
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
        progressView.setProgress(progress, animated: true)

        // **Update button title with remaining time in minutes**
        let remainingTime = totalCookingTime - elapsedTime
        let remainingSeconds = remainingTime % 60
        startTimerButton.setTitle("\(remainingSeconds)", for: .normal) // Update during testing to show remaining seconds
    }

    // Automatically show in-app notification when the cooking timer completes
    private func showCompletionNotification() {
            if !hasShownNotification {
                hasShownNotification = true
                
                // Change the button's background color to green
                startTimerButton.backgroundColor = UIColor.green
                
                // Change the progress view's tint color to green
                progressView.tintColor = UIColor.green
                
                let alert = UIAlertController(title: "Cooking Complete", message: "Your dish is ready!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Dismiss the alert
                    self.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
                sendLocalNotification()
            }
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
            details += "Rating: \(rating)/5"
        }

        // Present details in an alert or a new view
        let alert = UIAlertController(title: "Recipe Details", message: details, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
