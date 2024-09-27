import UIKit
import SDWebImage

class FavouriteRecipeCell: UITableViewCell {

    // Outlets connected to storyboard elements
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewInfoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // Configure the cell with recipe data
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title

        // Load image asynchronously using SDWebImage
        if let imageUrl = URL(string: recipe.image!) {
            recipeImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            recipeImageView.image = UIImage(named: "placeholder")
        }

        // Set button titles (if not set in storyboard)
        viewInfoButton.setTitle("View Info", for: .normal)
        deleteButton.setTitle("Remove", for: .normal)

        // Set button styles (optional)
        viewInfoButton.setTitleColor(.systemBlue, for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
    }
}
