import UIKit

// MARK: - Delegate Protocol
protocol AddRecipeDelegate: AnyObject {
    func didAddRecipe(_ recipe: Recipe)
}

class AddRecipeViewController: UIViewController {

    // MARK: - Delegate
    weak var delegate: AddRecipeDelegate?

    // MARK: - Outlets
    @IBOutlet weak var recipeTitleTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var timeRequiredTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add New Recipe"
        
        // Set up tap gesture for selecting images
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        recipeImageView.isUserInteractionEnabled = true
        recipeImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @IBAction func submitRecipeTapped(_ sender: UIButton) {
        // Ensure the fields are validated
        if validateFields() {
            // Collect the data entered by the user
            let title = recipeTitleTextField.text ?? ""
            let ingredients = ingredientsTextView.text ?? ""
            let cookingTime = Int(timeRequiredTextField.text ?? "0") ?? 0

            // Use a placeholder image URL for now
            let imageUrl = "https://via.placeholder.com/150"

            // Create a new Recipe object
            let newRecipe = Recipe(
                id: Int.random(in: 1000...9999),
                title: title,
                image: imageUrl,
                cookingTime: cookingTime,
                rating: nil,
                ingredients: ingredients.split(separator: ",").map { Ingredient(name: String($0)) },
                instructions: nil
            )

            // Notify the delegate (OwnRecipeViewController) that a new recipe has been added
            delegate?.didAddRecipe(newRecipe)
            
            // Dismiss AddRecipeViewController and go back to OwnRecipeViewController
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Validation
    private func validateFields() -> Bool {
        guard let title = recipeTitleTextField.text, !title.isEmpty else {
            showAlert("Title is required")
            return false
        }
        guard let ingredients = ingredientsTextView.text, !ingredients.isEmpty else {
            showAlert("Ingredients are required")
            return false
        }
        guard let timeText = timeRequiredTextField.text, !timeText.isEmpty, Int(timeText) != nil else {
            showAlert("Cooking time is invalid")
            return false
        }
        return true
    }

    // MARK: - Image Selection
    @objc private func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    // MARK: - Show Error Alert
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Image Picker Delegates
extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            recipeImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
