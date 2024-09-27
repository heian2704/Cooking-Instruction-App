import UIKit
import SDWebImage

class OwnRecipeTableCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!

    // MARK: - Cell Configuration Method
    func configure(with recipe: Recipe) {
        // Set recipe title
        titleLabel.text = recipe.title
        
        // Set cooking time if available
        if let cookingTime = recipe.cookingTime {
            cookingTimeLabel.text = "Cooking Time: \(cookingTime) mins"
        } else {
            cookingTimeLabel.text = "Cooking Time: N/A"
        }

        // Safely unwrap the ingredients array and join the ingredient names
        if let ingredients = recipe.ingredients {
            let ingredientNames = ingredients.map { $0.name }.joined(separator: ", ")
            ingredientsLabel.text = "Ingredients: \(ingredientNames)"
        } else {
            ingredientsLabel.text = "Ingredients: N/A"
        }

        // Load the image asynchronously with SDWebImage
        if let imageUrl = URL(string: recipe.image) {
            recipeImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"), options: [.progressiveLoad, .scaleDownLargeImages]) { [weak self] (image, error, cacheType, imageURL) in
                guard let strongSelf = self else { return }

                // Apply workaround to decode any potential buggy PNG images
                if let img = image {
                    let decodedImage = UIImage.sd_decodedImage(with: img)
                    strongSelf.recipeImageView.image = decodedImage
                } else {
                    strongSelf.recipeImageView.image = UIImage(named: "placeholder")
                }
            }
        } else {
            recipeImageView.image = UIImage(named: "placeholder")
        }

        // Style the image view
        recipeImageView.layer.cornerRadius = 10
        recipeImageView.layer.masksToBounds = true
    }
}
