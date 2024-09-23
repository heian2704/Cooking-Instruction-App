import UIKit

class AddRecipeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var recipeTitleTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var stepsTextView: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add New Recipe"
        
        // Add tap gesture to allow image selection
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        recipeImageView.isUserInteractionEnabled = true
        recipeImageView.addGestureRecognizer(tapGestureRecognizer)

        // Styling for the submit button (to ensure it's visible and styled well)
        setupSubmitButton()
    }

    // MARK: - Setup Submit Button Styling
    private func setupSubmitButton() {
        submitButton.layer.cornerRadius = 10
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitle("Submit Recipe", for: .normal)
        
        // Auto layout constraints to ensure it's visible
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: stepsTextView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions

    @IBAction func submitRecipeTapped(_ sender: UIButton) {
        guard let title = recipeTitleTextField.text, !title.isEmpty,
              let ingredients = ingredientsTextView.text, !ingredients.isEmpty,
              let steps = stepsTextView.text, !steps.isEmpty else {
            showAlert(message: "Please fill in all the fields.")
            return
        }
        
        // Save the recipe (this can be to a backend or local storage)
        saveRecipe(title: title, ingredients: ingredients, steps: steps)
        
        // Navigate back to the previous screen
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Image Picker for Image Upload
    @objc private func selectImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }

    // MARK: - Helper Methods

    private func saveRecipe(title: String, ingredients: String, steps: String) {
        // Add logic to save the recipe to the database or local storage
        print("New recipe saved - Title: \(title), Ingredients: \(ingredients), Steps: \(steps)")
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            recipeImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
