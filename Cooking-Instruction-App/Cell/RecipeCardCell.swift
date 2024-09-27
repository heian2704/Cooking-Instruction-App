import UIKit
import SDWebImage

class RecipeCardCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!  // Outlet for the title label
    @IBOutlet weak var actionButton: UIButton!  // Outlet for the button
    @IBOutlet weak var cardView: UIView!
    
    var buttonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        // Style the image view
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        // Style the button
        actionButton.layer.cornerRadius = 10
        actionButton.setTitle("Details", for: .normal)
        actionButton.backgroundColor = .systemYellow
        actionButton.setTitleColor(.white, for: .normal)
        
        cardView.layer.cornerRadius = 15// Rounded corners
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5// Light shadow
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 5
        cardView.layer.masksToBounds = false
    }
    
    func configure(with recipe: Recipe) {
        // Set the title and image for the recipe
        titleLabel.text = recipe.title
        if let imageUrl = URL(string: recipe.image!) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    @objc private func didTapButton() {
        buttonAction?()  // Call the action passed from the view controller
    }
}
