import UIKit
import SDWebImage

class RecipeDetailViewController: UIViewController {

    var recipe: Recipe?  // The property to hold the selected recipe

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch recipe details
        if let recipe = recipe {
            fetchRecipeDetails(recipeId: recipe.id)
        }
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
        
        // Safely unwrap and display cooking time
        cookingTimeLabel.text = recipe.cookingTime != nil ? "\(recipe.cookingTime!) min" : "N/A"
        
        // Safely unwrap and display rating
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
    
    // MARK: - Button Actions for Details and Recipe
    @IBAction func detailsButtonTapped(_ sender: UIButton) {
        guard let recipe = recipe else { return }

        var details = "Title: \(recipe.title)\n\n"
        if let ingredients = recipe.ingredients?.map({ $0.name }) {
            details += "Ingredients: \(ingredients.joined(separator: ", "))\n\n"
        }
        if let cookingTime = recipe.cookingTime {
            details += "Cooking Time: \(cookingTime) min\n\n"
        }
        if let rating = recipe.rating {
            details += "Rating: \(rating)/5"
        }

        infoLabel.text = details
    }

    @IBAction func recipeButtonTapped(_ sender: UIButton) {
        guard let recipe = recipe else { return }

        if let steps = recipe.instructions?.first?.steps {
            infoLabel.text = steps.map { "\($0.number). \($0.step)" }.joined(separator: "\n\n")
        } else {
            infoLabel.text = "No recipe steps available."
        }
    }
}
