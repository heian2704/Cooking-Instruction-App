//
//  CategoryCell.swift
//  Cooking-Instruction-App
//
//  Created by Thaw Htut Soe on 9/21/24.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with category: RecipeCategory) {
        titleLabel.text = category.name
    }
}
