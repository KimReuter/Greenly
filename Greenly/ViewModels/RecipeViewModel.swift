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
    var errorMessage: String?
    
    
    private let firestoreManager = FirestoreManager()
    
    func fetchRecipes() async {
        do {
            let snapshot = try await firestoreManager.db.collection("recipes").getDocuments()
            let fetchedRecipes = snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
            self.recipes = fetchedRecipes
            await checkAndUploadMissingRecipes(extistingRecipes: fetchedRecipes)
        } catch {
            print("Error loading recipes: \(error.localizedDescription)")
        }
    }
    
    private func checkAndUploadMissingRecipes(extistingRecipes: [Recipe]) async {
        do {
            let adminSnapshot = try await firestoreManager.db.collection("admin").document("predefinedRecipes").collection("recipes").getDocuments()
            let predefinedRecipes = adminSnapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
            for recipe in predefinedRecipes {
                if !extistingRecipes.contains(where: { $0.name == recipe.name }) {
                    try await firestoreManager.addPredefinedRecipe(recipe)
                    print("New Recipe '\(recipe.name) added automatically.")
                }
            }
        } catch {
            print("Error fetching predefined recipes: \(error.localizedDescription)")
        }
    }

    
    func addRecipe(_ recipe: Recipe) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "Nos user logged in"
            return
        }
        do {
            try await firestoreManager.addUserRecipe(recipe, userID: userID)
            recipes.append(recipe)
        } catch {
            errorMessage = "Error adding recipe: \(error.localizedDescription)"
        }
    }
    
    func deleteRecipe(recipeID: String) async {
        do {
            try await firestoreManager.db.collection("recipes").document(recipeID).delete()
            recipes.removeAll() { $0.id.uuidString == recipeID }
        } catch {
            errorMessage = "Error deleting recipe: \(error.localizedDescription)"
        }
    }
    
    func addFavoriteRecipe(_ recipeID: String) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        do {
            try await firestoreManager.addRecipeToFavourites(userID: userID, recipeID: recipeID)
        } catch {
            errorMessage = "Error adding to favorites: \(error.localizedDescription)"
        }
    }
    
    func removeRecipeFromFavorites(recipeID: String) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        do {
            try await firestoreManager.removeRecipeFromFavorites(userID: userID, recipeID: recipeID)
        } catch {
            errorMessage = "Error removing from favorites: \(error.localizedDescription)"
        }
    }
    
    func filterRecipes(by category: RecipeCategory) -> [Recipe] {
        return recipes.filter { $0.category == category }
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        return recipes.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
}
