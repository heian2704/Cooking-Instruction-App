import Foundation
import Alamofire

class RecipeDetailViewModel {
    
    private let apiKey = "89f9b9589ba048e89ba87fc0a2326096" // Replace this with your Spoonacular API Key
    //89f9b9589ba048e89ba87fc0a2326096
    //ca11b4f219254477b899c25d794a3cf3
    // Fetch recipe details (including ingredients and steps) by recipe ID
    func fetchRecipeDetails(by id: Int, completion: @escaping (Recipe?) -> Void) {
        let detailsUrl = "https://api.spoonacular.com/recipes/\(id)/information"
        let parameters: [String: String] = [
            "apiKey": apiKey,
            "includeNutrition": "false",
            "addRecipeInformation": "true",  // This will include more recipe details
            "fillIngredients": "true"        // Ensure ingredients are filled
        ]
        
        AF.request(detailsUrl, method: .get, parameters: parameters).responseDecodable(of: Recipe.self) { response in
            switch response.result {
            case .success(let recipeDetails):
                completion(recipeDetails)
            case .failure(let error):
                print("Failed to fetch recipe details: \(error)")
                completion(nil)
            }
        }
    }
}
