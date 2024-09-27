import Foundation

struct RecipeResponse: Codable {
    let results: [Recipe]
}

struct Recipe: Codable {
    let id: Int
    let title: String
    var image: String?  // Support both web URLs and optional images
    var imagePath: String?  // Add a path for local images
    let cookingTime: Int?  // Example field: "readyInMinutes"
    let rating: Double?  // Example field: "spoonacularScore"
    let ingredients: [Ingredient]?  // Correct mapping for `extendedIngredients`
    let instructions: [Instruction]?  // Correct mapping for `analyzedInstructions`

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case cookingTime = "readyInMinutes"
        case rating = "spoonacularScore"
        case ingredients = "extendedIngredients"
        case instructions = "analyzedInstructions"
    }
}

struct Ingredient: Codable {
    let name: String
}

struct Instruction: Codable {
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let step: String
}
