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
    var filteredRecipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var errorMessage: String?
    
    var searchQuery: String = "" // Suchtext (Name oder Beschreibung)
    var selectedCategory: Set<RecipeCategory> = [] // ✅ Set
    var selectedIngredient: String = "" // Gesuchte Zutat
    
    
    func applyFilters() async {
        filteredRecipes = recipes.filter { recipe in
            let matchesSearchText = searchQuery.isEmpty ||
                recipe.name.localizedCaseInsensitiveContains(searchQuery) ||
                recipe.description.localizedCaseInsensitiveContains(searchQuery)
            
            let matchesCategory = selectedCategory.isEmpty ||
                recipe.category.contains { selectedCategory.contains($0) }
            
            let matchesIngredient = (selectedIngredient.isEmpty) ||
                (recipe.ingredients?.contains { $0.name.localizedCaseInsensitiveContains(selectedIngredient) } ?? false)

            return matchesSearchText && matchesCategory && matchesIngredient
        }
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
    
    func clearFilter(_ filterType: FilterType) async {
        switch filterType {
        case .searchQuery:
            searchQuery = ""
        case .category:
            // 🔥 Nur die eine Kategorie entfernen, nicht alle!
            if let firstCategory = selectedCategory.first {
                selectedCategory.remove(firstCategory)
            }
        case .ingredient:
            selectedIngredient = ""
        }

        await applyFilters() // 🔥 Aktualisiere nur mit den noch gesetzten Filtern
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
