import UIKit

class OwnRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRecipeDelegate {

    @IBOutlet weak var tableView: UITableView!

    // Array to store recipes
    private var ownRecipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Own Recipes"
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
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
        
        return cell
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
}
