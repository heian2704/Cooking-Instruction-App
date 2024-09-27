import UIKit
import FirebaseAuth

class FavouriteRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!  // Label for showing user email

    private var favouriteRecipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load user profile (email)
        loadUserProfile()

        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Auto Reload When View Appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the table every time the view appears
        loadFavouriteRecipes()
    }

    // MARK: - Load User Profile
    func loadUserProfile() {
        // Ensure that the user is logged in before accessing the profile
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            emailLabel.text = "Not logged in"  // Handle case when no user is logged in
            return
        }
        // Display user's email in the label
        emailLabel.text = user.email
    }

    // MARK: - Load Favorite Recipes
    func loadFavouriteRecipes() {
        // Fetch favorite recipes from the manager
        favouriteRecipes = FavoriteRecipesManager.shared.getFavorites()

        // Debugging: Check if recipes are fetched properly
        print("Favorite Recipes Loaded: \(favouriteRecipes.count)")

        // Reload the table view after fetching
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom FavouriteRecipeCell from the storyboard
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteRecipeCell", for: indexPath) as? FavouriteRecipeCell else {
            return UITableViewCell()
        }

        // Get the corresponding recipe for the current row
        let recipe = favouriteRecipes[indexPath.row]

        // Configure the cell with the recipe details
        cell.configure(with: recipe)

        // Handle the View Info button action
        cell.viewInfoButton.tag = indexPath.row
        cell.viewInfoButton.addTarget(self, action: #selector(viewInfoTapped(_:)), for: .touchUpInside)

        // Handle the Delete button action
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)

        return cell
    }

    // MARK: - View Info Action
    @objc private func viewInfoTapped(_ sender: UIButton) {
        let selectedRecipe = favouriteRecipes[sender.tag]
        navigateToRecipeDetail(recipe: selectedRecipe)
    }

    // Navigate to Recipe Detail
    private func navigateToRecipeDetail(recipe: Recipe) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            detailVC.recipe = recipe
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    // MARK: - Delete Recipe Action
    @objc private func deleteTapped(_ sender: UIButton) {
        let selectedRecipe = favouriteRecipes[sender.tag]

        // Remove the recipe from the FavoriteRecipesManager
        FavoriteRecipesManager.shared.remove(selectedRecipe)

        // Refresh the local array of favorite recipes
        loadFavouriteRecipes()
    }
}
