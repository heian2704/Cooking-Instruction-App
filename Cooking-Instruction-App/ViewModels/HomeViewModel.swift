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
    
    private let apiKey = "b54243df5dd64b8bbda2eeb0cb8ae48a"
    private let baseUrl = "https://api.spoonacular.com/recipes/complexSearch"
    
    // MARK: - Fetch Recipes from API
    func fetchRecipes(query: String = "", category: String = "", maxReadyTime: Int? = nil) {
        var parameters: [String: Any] = [
            "query": query,
            "apiKey": apiKey,
            "fillIngredients": true,
            "addRecipeInformation": true,
            "addRecipeInstructions": true
        ]
        
        // Add maxReadyTime if it's provided
        if let maxTime = maxReadyTime {
            parameters["maxReadyTime"] = maxTime
        }
        
        // Add category filtering if a category is provided
        if !category.isEmpty && category != "All" {
            parameters["type"] = category.lowercased()
        }
        
        // Fetch from API
        AF.request(baseUrl, method: .get, parameters: parameters).responseDecodable(of: RecipeResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                self.recipes = recipeResponse.results
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
        // Fetch recipes again but this time filtered by the category
        fetchRecipes(query: "", category: category)
    }
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
