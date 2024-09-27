import UIKit
import SDWebImage

class OwnRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRecipeDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let ownRecipesKey = "ownRecipes" // Key for saving in UserDefaults

    // Array to store recipes
    private var ownRecipes: [Recipe] = [] {
        didSet {
            // Save the updated recipes array whenever it changes
            saveRecipes()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Own Recipes"
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        // Load saved recipes from UserDefaults
        loadRecipes()
    }

    // MARK: - AddRecipeDelegate Method
    func didAddRecipe(_ recipe: Recipe) {
        // Add the new recipe to the array
        ownRecipes.append(recipe)
        print("New Recipe Added: \(recipe.title), Cooking Time: \(recipe.cookingTime ?? 0)")
        // Reload the table view to reflect the new recipe
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OwnRecipeTableCell", for: indexPath) as? OwnRecipeTableCell else {
            return UITableViewCell()
        }
        // Get the recipe for the current row
        let recipe = ownRecipes[indexPath.row]
        // Configure the cell with the recipe details (this is the custom configure method)
        cell.configure(with: recipe)
        
        // Set up delete button action
        cell.onDeleteButtonTapped = { [weak self] in
            self?.confirmDeleteRecipe(at: indexPath)
        }
        
        return cell
    }

    // MARK: - Navigation to RecipeDetailViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected recipe
        let recipe = ownRecipes[indexPath.row]

        // Instantiate the RecipeDetailViewController from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            
            // Pass the selected recipe to the detail view controller
            detailVC.recipe = recipe
            
            // Set isLocalRecipe to true because this recipe is local
            detailVC.isLocalRecipe = true
            
            // Navigate to RecipeDetailViewController
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    // Confirm the deletion with an alert
    private func confirmDeleteRecipe(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteRecipe(at: indexPath)
        }))
        present(alert, animated: true)
    }

    // Delete recipe and update the table view
    private func deleteRecipe(at indexPath: IndexPath) {
        ownRecipes.remove(at: indexPath.row)
        
        // Reload the entire table view after deleting an item
        tableView.reloadData()
    }

    // MARK: - Navigation to AddRecipeViewController
    @IBAction func addRecipeTapped(_ sender: UIBarButtonItem) {
        // Load AddRecipeViewController from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addRecipeVC = storyboard.instantiateViewController(withIdentifier: "AddRecipeViewController") as? AddRecipeViewController {
            // Set the delegate so AddRecipeViewController can pass data back
            addRecipeVC.delegate = self
            // Navigate to AddRecipeViewController
            navigationController?.pushViewController(addRecipeVC, animated: true)
        }
    }

    // MARK: - Saving and Loading Recipes with UserDefaults

    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(ownRecipes) {
            UserDefaults.standard.set(encoded, forKey: ownRecipesKey)
        }
    }

    private func loadRecipes() {
        if let savedData = UserDefaults.standard.data(forKey: ownRecipesKey),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: savedData) {
            ownRecipes = decoded
        }
    }
}
