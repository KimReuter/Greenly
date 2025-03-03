//
//  RecipeManager.swift
//  Greenly
//
//  Created by Kim Reuter on 20.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@Observable
final class RecipeManager {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - 📥 Rezepte abrufen
    func fetchRecipes() async throws -> [Recipe] {
        let snapshot = try await db.collection("recipes").getDocuments()
        var recipes: [Recipe] = []

        for document in snapshot.documents {
            do {
                var recipe = try document.data(as: Recipe.self)
                
                // 🔥 Zutaten aus Unterkollektion abrufen
                let ingredients = try await fetchIngredients(forRecipeID: document.documentID)
                recipe.ingredients = ingredients

                recipes.append(recipe)
            } catch {
                throw RecipeError.decodingFailed(reason: error.localizedDescription)
            }
        }
        return recipes
    }

    // MARK: - 📥 Zutaten abrufen
    func fetchIngredients(forRecipeID recipeID: String) async throws -> [Ingredient] {
        let ingredientsRef = db.collection("recipes").document(recipeID).collection("ingredients")

        print("📂 Firestore Collection Path: recipes/\(recipeID)/ingredients")
        
        let snapshot = try await ingredientsRef.getDocuments()
        
        print("🔥 Firestore Snapshot Größe: \(snapshot.documents.count)")

        for doc in snapshot.documents {
            print("📄 Dokument gefunden: \(doc.documentID) - Daten: \(doc.data())")
        }

        let ingredients = snapshot.documents.compactMap { document -> Ingredient? in
            guard let name = document["name"] as? String else {
                print("⚠️ Fehler: Zutat hat keinen Namen! Dokument ID: \(document.documentID)")
                return nil
            }
            let quantity = document["quantity"] as? Double ?? 1.0
            return Ingredient(name: name, quantity: quantity)
        }

        print("✅ Zutaten extrahiert: \(ingredients.count)")
        return ingredients
    }

    // MARK: - 📤 Rezept erstellen
    func createRecipe(_ recipe: Recipe) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw RecipeError.noUserLoggedIn
        }

        let recipeRef = db.collection("recipes").document() // Neuen Rezept-Dokument erstellen
        var recipeData = try Firestore.Encoder().encode(recipe)
        recipeData["author"] = userID

        // 🔥 Zutaten aus der Hauptstruktur entfernen (falls vorhanden)
        recipeData.removeValue(forKey: "ingredients")

        try await recipeRef.setData(recipeData) // 🔥 Speichert Rezept-Daten OHNE Zutaten als Array!

        // 🔥 Zutaten als Unterkollektion speichern
        for ingredient in recipe.ingredients ?? [] {
            let ingredientRef = recipeRef.collection("ingredients").document()
            try await ingredientRef.setData([
                "name": ingredient.name,
                "quantity": ingredient.quantity ?? 0.0 // Falls nil, Standardwert 0.0
            ])
            print("✅ Zutat gespeichert: \(ingredient.name)")
        }

        print("✅ Rezept erfolgreich gespeichert: \(recipe.name)")
    }

    // MARK: - 🛒 Einkaufsliste verwalten
    func addIngredientToShoppingList(_ ingredient: Ingredient) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let shoppingListRef = db.collection("users").document(userID).collection("shoppingList").document()
        try await shoppingListRef.setData([
            "name": ingredient.name,
            "quantity": ingredient.quantity
        ])
    }

    func fetchShoppingList() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("shoppingList").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Ingredient.self) }
    }

    func removeIngredientFromShoppingList(_ ingredientID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let shoppingListRef = db.collection("users").document(userID).collection("shoppingList").document(ingredientID)
        try await shoppingListRef.delete()
    }

    // MARK: - 📦 Vorrat verwalten
    func addIngredientToInventory(_ ingredient: Ingredient) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let inventoryRef = db.collection("users").document(userID).collection("inventory").document()
        try await inventoryRef.setData([
            "name": ingredient.name,
            "quantity": ingredient.quantity
        ])
    }

    func fetchInventory() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("inventory").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Ingredient.self) }
    }

    func removeIngredientFromInventory(_ ingredientID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let inventoryRef = db.collection("users").document(userID).collection("inventory").document(ingredientID)
        try await inventoryRef.delete()
    }
}

// MARK: - 🔥 Fehlerhandling
enum RecipeError: LocalizedError {
    case noUserLoggedIn
    case decodingFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .noUserLoggedIn:
            return "Kein Benutzer eingeloggt."
        case .decodingFailed(let reason):
            return "Fehler beim Dekodieren: \(reason)"
        }
    }
}
