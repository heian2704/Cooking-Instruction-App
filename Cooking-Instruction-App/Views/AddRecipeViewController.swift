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

    private var selectedImagePath: String?

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

            // Use the selected image path, or use a placeholder image if not selected
            let imageUrl = selectedImagePath ?? "https://via.placeholder.com/150"

            // Create a new Recipe object
            let newRecipe = Recipe(
                id: Int.random(in: 1000...9999),
                title: title,
                image: imageUrl, // This is now the local file path of the selected image
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

    // MARK: - Save Image to Documents Directory
    private func saveImageToDocumentsDirectory(image: UIImage) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            if let documentsDirectory = urls.first {
                let fileName = UUID().uuidString + ".jpg"
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    return fileURL.path
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        return nil
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
            
            // Save the image to the app's documents directory
            if let imagePath = saveImageToDocumentsDirectory(image: selectedImage) {
                self.selectedImagePath = imagePath
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
