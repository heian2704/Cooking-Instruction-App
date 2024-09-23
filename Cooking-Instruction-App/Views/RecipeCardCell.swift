import UIKit
import SDWebImage

class RecipeCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!  // Outlet for the title label
    @IBOutlet weak var actionButton: UIButton!
    
    var buttonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        actionButton.layer.cornerRadius = 10
        actionButton.setTitle("Details", for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        if let imageUrl = URL(string: recipe.image) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    @objc private func didTapButton() {
        buttonAction?()
    }
}

