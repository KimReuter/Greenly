//
//  RecipeViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@Observable
final class RecipeViewModel {
    
    var recipes: [Recipe] = []
    var categorie: [RecipeCategory] = []
    var favoriteRecipes: [Recipe] = []
    var filteredRecipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var errorMessage: String?
    
    var searchQuery: String = "" // Suchtext (Name oder Beschreibung)
    var selectedCategory: RecipeCategory? = nil // Gewählte Kategorie
    var selectedIngredient: String = "" // Gesuchte Zutat
    
    
    func applyFilters() async {
            await MainActor.run {
                self.filteredRecipes = self.recipes.filter { recipe in
                    let matchesSearchText = self.searchQuery.isEmpty ||
                        recipe.name.localizedCaseInsensitiveContains(self.searchQuery) ||
                        recipe.description.localizedCaseInsensitiveContains(self.searchQuery)
                    
                    let matchesCategory = self.selectedCategory == nil ||
                        recipe.category.contains(self.selectedCategory!)
                    
                    let matchesIngredient = self.selectedIngredient.isEmpty ||
                        (recipe.ingredients?.contains { $0.name.localizedCaseInsensitiveContains(self.selectedIngredient) } ?? false)

                    return matchesSearchText && matchesCategory && matchesIngredient
                }
            }
        }
    
    func isRecipeFavorite(_ recipe: Recipe) -> Bool {
        let isFav = favoriteRecipes.contains { $0.id == recipe.id }
        return isFav
    }
    
    func fetchRecipes() async {
        do {
            let loadedRecipes = try await recipeManager.fetchRecipes()
            recipes = loadedRecipes
            filteredRecipes = loadedRecipes
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addFavoriteRecipe(recipeID: String) async {
        do {
            try await recipeManager.addFavoriteRecipe(recipeID)
            await fetchFavoriteRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchFavoriteRecipes() async {
        do {
            let loadedFavorites = try await recipeManager.fetchFavoriteRecipes()
            favoriteRecipes = loadedFavorites
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFavorite(recipe: Recipe) async {
        guard let recipeID = recipe.id else { return }
        
        if isRecipeFavorite(recipe) {
            do {
                try await recipeManager.removeFavoriteRecipe(recipeID)
                favoriteRecipes.removeAll { $0.id == recipeID }
                try await Task.sleep(nanoseconds: 300_000_000)
                await fetchFavoriteRecipes()
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            do {
                try await recipeManager.addFavoriteRecipe(recipeID)
                favoriteRecipes.append(recipe)
                try await Task.sleep(nanoseconds: 300_000_000)
                await fetchFavoriteRecipes()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func getRecipes(for category: RecipeCategory) -> [Recipe] {
        recipes.filter { $0.category.contains(category) }
    }
    
    func fetchIngredients(for recipe: Recipe) async {
        guard let recipeID = recipe.id else { return }
        
        do {
            let loadedIngredients = try await recipeManager.fetchIngredients(forRecipe: recipeID)
            
            if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
                recipes[index].ingredients = loadedIngredients
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    init() {
        Task {
            await fetchRecipes()
        }
    }
    
    private let recipeManager = RecipeManager()
    
    //    private func checkAndUploadMissingRecipes(extistingRecipes: [Recipe]) async {
    //        do {
    //            let adminSnapshot = try await firestoreManager.db.collection("admin").document("predefinedRecipes").collection("recipes").getDocuments()
    //            let predefinedRecipes = adminSnapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    //            for recipe in predefinedRecipes {
    //                if !extistingRecipes.contains(where: { $0.name == recipe.name }) {
    //                    try await firestoreManager.addPredefinedRecipe(recipe)
    //                    print("New Recipe '\(recipe.name) added automatically.")
    //                }
    //            }
    //        } catch {
    //            print("Error fetching predefined recipes: \(error.localizedDescription)")
    //        }
    //    }
    
    
    //    func addRecipe(_ recipe: Recipe, imageData: Data?) async throws {
    //        let recipeRef = Firestore.firestore().collection("recipes").document(recipe.id.uuidString)
    //        do {
    //            var newRecipe = recipe
    //            newRecipe.pictureURL = nil
    //            newRecipe.createdByAdmin = isAdmin()
    //            try await recipeRef.setData(from: newRecipe)
    //            if let imageData = imageData {
    //                let imageURL = try await FirestoreManager().uploadImage(imageData, recipeID: recipe.id.uuidString)
    //                try await recipeRef.updateData(["pictureURL": imageURL])
    //            }
    //            print("Recipe succesfully uploaded!")
    //        } catch {
    //            try await recipeRef.delete()
    //            throw error
    //        }
    //    }
    
    //    func deleteRecipe(recipeID: String) async {
    //        do {
    //            try await firestoreManager.db.collection("recipes").document(recipeID).delete()
    //            recipes.removeAll() { $0.id.uuidString == recipeID }
    //        } catch {
    //            errorMessage = "Error deleting recipe: \(error.localizedDescription)"
    //        }
    //    }
    
    
    
    //    func removeRecipeFromFavorites(recipeID: String) async {
    //        guard let userID = Auth.auth().currentUser?.uid else {
    //            errorMessage = "No user logged in"
    //            return
    //        }
    //        do {
    //            try await firestoreManager.removeRecipeFromFavorites(userID: userID, recipeID: recipeID)
    //        } catch {
    //            errorMessage = "Error removing from favorites: \(error.localizedDescription)"
    //        }
    //    }
    
    //    func filterRecipes(by category: RecipeCategory) -> [Recipe] {
    //        return recipes.filter { $0.category == category }
    //    }
    
    //    func searchRecipes(query: String) -> [Recipe] {
    //        return recipes.filter { $0.name.lowercased().contains(query.lowercased()) }
    //    }
}
