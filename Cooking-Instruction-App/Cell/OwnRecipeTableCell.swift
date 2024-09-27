import UIKit

class OwnRecipeTableCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton! // Add this outlet

    // MARK: - Cell Configuration Method
    var onDeleteButtonTapped: (() -> Void)? // Callback for delete action

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
        // Load the image - check if it's a local file path
        if recipe.image!.starts(with: "/") {
                  // Load from local directory
            if let image = UIImage(contentsOfFile: recipe.image!) {
                      recipeImageView.image = image
                  } else {
                      recipeImageView.image = UIImage(named: "placeholder")
                  }
              } else {
                  // Load from URL (SDWebImage)
                  if let imageUrl = URL(string: recipe.image!) {
                      recipeImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
                  } else {
                      recipeImageView.image = UIImage(named: "placeholder")
                  }
              }

        // Style the image view
        recipeImageView.layer.cornerRadius = 10
        recipeImageView.layer.masksToBounds = true

        // Attach action to delete button
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func deleteButtonTapped() {
        onDeleteButtonTapped?() // Trigger the callback for delete
    }
}
