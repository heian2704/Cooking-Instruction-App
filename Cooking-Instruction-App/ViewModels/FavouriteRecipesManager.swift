import Foundation

class FavoriteRecipesManager {
    static let shared = FavoriteRecipesManager()
    
    private var favoriteRecipes: [Recipe] = []
    
    private init() { }
    
    func add(_ recipe: Recipe) {
        if !favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            favoriteRecipes.append(recipe)
        }
    }
    
    func remove(_ recipe: Recipe) {
        favoriteRecipes.removeAll { $0.id == recipe.id }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        return favoriteRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func getFavorites() -> [Recipe] {
        return favoriteRecipes
    }
}
