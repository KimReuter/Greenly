//
//  RecipeManager.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import FirebaseFirestore
import FirebaseStorage

class FirestoreManager {
    
    let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    func addPredefinedRecipe(_ recipe: Recipe) async throws {
        let recipeRef = db.collection("recipes").document(recipe.id.uuidString)
        let data = try Firestore.Encoder().encode(recipe)
        try await recipeRef.setData(data)
    }
    
    func addUserRecipe(_ recipe: Recipe, userID: String) async throws {
        let recipeRef = db.collection("recipes").document(recipe.id.uuidString)
        var recipeData = try Firestore.Encoder().encode(recipe)
        recipeData["author"] = userID
        try await recipeRef.setData(recipeData)
    }
    
    func addRecipeToFavourites(userID: String, recipeID: String) async throws {
        let userRef = db.collection("users").document(userID)
        try await userRef.updateData([
            "favoriteRecipeIDs": FieldValue.arrayUnion([recipeID])
        ])
    }
    
    func getFavoriteRecipes(userID: String) async throws -> [String] {
        let userRef = db.collection("users").document(userID)
        let snapshot = try await userRef.getDocument()
        
        guard let data = snapshot.data(),
              let recipeIDs = data["favoriteRecipeIDs"] as? [String] else {
            return []
        }
        return recipeIDs
    }
    
    func removeRecipeFromFavorites(userID: String, recipeID: String) async throws {
        let userRef = db.collection("users").document(userID)
        try await userRef.updateData([
            "favoriteRecipeIDs": FieldValue.arrayRemove([recipeID])
        ])
    }
    
    func uploadImage(_ imageData: Data, recipeID: String) async throws -> String {
        let storageRef = storage.reference().child("recipeImages/\(recipeID).jpg")
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            throw error
        }
    }
    
}
