import Foundation
import Alamofire

class HomeViewModel {
    
    var onRecipesFetched: (() -> Void)?
    var onCategoriesFetched: (() -> Void)?
    
    var recipes: [Recipe] = [] {
        didSet {
            self.filteredRecipes = recipes
            onRecipesFetched?()
        }
    }
    
    var filteredRecipes: [Recipe] = []
    
    var categories: [RecipeCategory] = [] {
        didSet {
            onCategoriesFetched?()
        }
    }
    //demo-key=89f9b9589ba048e89ba87fc0a2326096
    //ca11b4f219254477b899c25d794a3cf3
    private let apiKey = "89f9b9589ba048e89ba87fc0a2326096"
    private let baseUrl = "https://api.spoonacular.com/recipes/complexSearch"
    
    // To avoid unnecessary repeated API calls
    private var hasFetchedAllRecipes: Bool = false
    
    // MARK: - Fetch Recipes from API
    func fetchRecipes(query: String = "", category: String = "", maxReadyTime: Int? = nil, forceRefresh: Bool = false) {
        // If already fetched all recipes and no force refresh, avoid calling the API again
        if hasFetchedAllRecipes && query.isEmpty && category.isEmpty && !forceRefresh {
            self.filteredRecipes = self.recipes
            onRecipesFetched?()
            return
        }

        var parameters: [String: Any] = [
            "apiKey": apiKey,
            "fillIngredients": true,
            "addRecipeInformation": true,
            "addRecipeInstructions": true,
            "number": 30  // Fetch 30 recipes instead of the default 10
        ]
        
        // Add query if provided
        if !query.isEmpty {
            parameters["query"] = query
        }
        
        // Add category filtering if provided and not "All"
        if !category.isEmpty && category != "All" {
            parameters["type"] = category.lowercased()
        }

        // Add maxReadyTime if provided
        if let maxTime = maxReadyTime {
            parameters["maxReadyTime"] = maxTime
        }

        // Fetch from API
        AF.request(baseUrl, method: .get, parameters: parameters).responseDecodable(of: RecipeResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                // Store and cache recipes
                if query.isEmpty && category.isEmpty {
                    self.recipes = recipeResponse.results
                    self.hasFetchedAllRecipes = true // Cache the result to avoid refetch
                }
                // Update filtered recipes
                self.filteredRecipes = recipeResponse.results
                self.onRecipesFetched?() // Notify the view to reload
            case .failure(let error):
                print("Failed to fetch recipes: \(error)")
            }
        }
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() {
        categories = [
            RecipeCategory(name: "All"),
            RecipeCategory(name: "Breakfast"),
            RecipeCategory(name: "Lunch"),
            RecipeCategory(name: "Dinner"),
            RecipeCategory(name: "Desserts")
        ]
    }

    // MARK: - Filter Recipes by Category
    func filterRecipes(by category: String) {
        if category == "All" {
            // Fetch all recipes (reset filtering)
            fetchRecipes(query: "")
        } else {
            // Fetch recipes filtered by the selected category
            fetchRecipes(query: "", category: category)
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthService.shared.signOut { result in
            switch result {
            case .success:
                completion(.success(())) // Notify success
            case .failure(let error):
                completion(.failure(error)) // Notify failure with error
            }
        }
    }
}
