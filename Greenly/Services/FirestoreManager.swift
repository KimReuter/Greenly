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
    
    func addUserRecipe(_ recipe: Recipe, userID: String) async throws {
        // Falls keine ID vorhanden, neue generieren
        var recipeToAdd = recipe
        if recipeToAdd.id == nil {
            recipeToAdd.id = UUID().uuidString
        }
        
        let recipeRef = db.collection("recipes").document(recipeToAdd.id!)
        var recipeData = try Firestore.Encoder().encode(recipeToAdd)
        recipeData["author"] = userID
        try await recipeRef.setData(recipeData)
        
        // Zutaten als Subcollection abspeichern, falls vorhanden
        if let ingredients = recipeToAdd.ingredients {
            for ingredient in ingredients {
                let ingredientRef = recipeRef.collection("ingredients").document()
                try await ingredientRef.setData(from: ingredient)
            }
        }
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
    
    func fetchIngredients(forRecipeID recipeID: String) async throws -> [Ingredient] {
        let ingredientsRef = db.collection("recipes").document(recipeID).collection("ingredients")
        let snapshot = try await ingredientsRef.getDocuments()

        return snapshot.documents.compactMap { document in
            try? document.data(as: Ingredient.self)
        }
    }
    
//    func uploadImage(_ imageData: Data, recipeID: String) async throws -> String {
//        let storageRef = storage.reference().child("recipeImages/\(recipeID).jpg")
//        do {
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            _ = try await storageRef.downloadURL()
//            return downloadURL.absoluteString
//        } catch {
//            throw error
//        }
//    }
    
}
