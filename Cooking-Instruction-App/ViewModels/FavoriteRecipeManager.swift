import Foundation

class FavoriteRecipesManager {
    static let shared = FavoriteRecipesManager()

    private let favoritesKey = "favoriteRecipes"
    private var favoriteRecipes: [Recipe] = []

    private init() {
        loadFavorites() // Load from UserDefaults when the app starts
    }

    // Add a recipe to the favorites, if not already added
    func add(_ recipe: Recipe) {
        if !favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            favoriteRecipes.append(recipe)
            saveFavorites() // Save the updated favorites
            print("Recipe added to favorites: \(recipe.title)")
        }
    }

    // Remove a recipe from the favorites
    func remove(_ recipe: Recipe) {
        favoriteRecipes.removeAll { $0.id == recipe.id }
        saveFavorites() // Save the updated favorites
        print("Recipe removed from favorites: \(recipe.title)")
    }

    // Check if a recipe is already a favorite
    func isFavorite(_ recipe: Recipe) -> Bool {
        return favoriteRecipes.contains(where: { $0.id == recipe.id })
    }

    // Get all favorite recipes
    func getFavorites() -> [Recipe] {
        return favoriteRecipes
    }

    // MARK: - Persistence using UserDefaults

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteRecipes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let savedData = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: savedData) {
            favoriteRecipes = decoded
        }
    }
}
