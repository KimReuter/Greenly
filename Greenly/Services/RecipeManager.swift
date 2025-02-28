//
//  RecipeManager.swift
//  Greenly
//
//  Created by Kim Reuter on 20.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
final class RecipeManager {
    
    private let firestoreManager = FirestoreManager()
    
    func fetchRecipes() async throws -> [Recipe] {
        let snapshot = try await firestoreManager.db.collection("recipes").getDocuments()
        var recipes: [Recipe] = []

        for document in snapshot.documents {
            do {
                var recipe = try document.data(as: Recipe.self)

                let ingredients = try await firestoreManager.fetchIngredients(forRecipeID: document.documentID)
                recipe.ingredients = ingredients

                recipes.append(recipe)
            } catch {
                throw Error.decodingRecipeFailed(reason: error.localizedDescription)
            }
        }
        return recipes
    }
    
    func addFavoriteRecipe(_ recipeID: String) async throws(Error) {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw .noUserLoggedIn(reason: "User must be logged in to add favorites.")
        }
        
        let userRef = firestoreManager.db.collection("users").document(userID)
        
        do {
            let document = try await userRef.getDocument()
            if !document.exists {
                try await userRef.setData(["favoriteRecipeIDs": []])
            }
            
            try await userRef.updateData([
                "favoriteRecipeIDs": FieldValue.arrayUnion([recipeID])
            ])
        } catch {
            throw .fireStoreError(reason: error.localizedDescription)
        }
    }
    
    func fetchFavoriteRecipes() async throws -> [Recipe] {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw Error.noUserLoggedIn(reason: "User must be logged in to fetch favorites")
        }
        
        let favoriteRecipeIDs = try await firestoreManager.getFavoriteRecipes(userID: userID)
        
        if favoriteRecipeIDs.isEmpty {
            return []
        }
        
        var favoriteRecipes: [Recipe] = []
        for recipeID in favoriteRecipeIDs {
            let document = try await firestoreManager.db.collection("recipes").document(recipeID).getDocument()
            if let recipe = try? document.data(as: Recipe.self) {
                favoriteRecipes.append(recipe)
            }
        }
        return favoriteRecipes
    }
    
    func removeFavoriteRecipe(_ recipeID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw Error.noUserLoggedIn(reason: "User must be logged in to fetch favorites")
        }
        
        let userRef = firestoreManager.db.collection("users").document(userID)

        let document = try await userRef.getDocument()
        if !document.exists {
            return
        }
        
        try await userRef.updateData([
            "favoriteRecipeIDs": FieldValue.arrayRemove([recipeID])
        ])
    }
    
    func fetchIngredients(forRecipe recipeID: String) async throws -> [Ingredient] {
        try await firestoreManager.fetchIngredients(forRecipeID: recipeID)
    }
    
    func createRecipe(_ recipe: Recipe) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw Error.noUserLoggedIn(reason: "User muss eingeloggt sein, um ein Rezept zu erstellen.")
        }
        try await firestoreManager.addUserRecipe(recipe, userID: userID)
    }
    
    enum Error: LocalizedError {
        case decodingRecipeFailed(reason: String)
        case addToFavoriteFailed(reason: String)
        case noUserLoggedIn(reason: String)
        case fireStoreError(reason: String)
        
        var errorDescription: String? {
            switch self {
            case .decodingRecipeFailed(let reason): "Decoding Recipe failed: \(reason)"
            case .addToFavoriteFailed(let reason): "Add to Favorites failed: \(reason)"
            case .noUserLoggedIn(let  reason): "No User logged in: \(reason)"
            case .fireStoreError(let reason): "Firestore Error: \(reason)"
            }
        }
    }
    

    
}
