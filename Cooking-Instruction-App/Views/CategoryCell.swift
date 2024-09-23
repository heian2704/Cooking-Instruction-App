import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with category: RecipeCategory) {
        titleLabel.text = category.name
    }
}
