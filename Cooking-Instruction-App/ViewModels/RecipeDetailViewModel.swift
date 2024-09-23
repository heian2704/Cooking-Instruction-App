import Foundation
import Alamofire

class RecipeDetailViewModel {
    
    private let apiKey = "b54243df5dd64b8bbda2eeb0cb8ae48a" // Replace this with your Spoonacular API Key
    
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
