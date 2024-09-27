import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    // Configure the cell with the category name and selection state
    func configure(with category: RecipeCategory, isSelected: Bool) {
        titleLabel.text = category.name
        if isSelected {
            setSelected()     // Apply yellow border and highlight
        } else {
            setUnselected()   // Remove highlight
        }
    }

    func setSelected() {
        self.layer.borderColor = UIColor.systemYellow.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        titleLabel.textColor = UIColor.black
    }

    func setUnselected() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
        titleLabel.textColor = UIColor.black
    }
}
