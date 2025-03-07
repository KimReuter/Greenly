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
    private var listener: ListenerRegistration?
    private var inventoryListener: ListenerRegistration?
    
    
    // MARK: - 📡 Snapshot Listener für Rezepte
    func observeRecipes(onChange: @escaping ([Recipe]) -> Void) throws {
        listener?.remove() // 🔥 Falls ein alter Listener existiert, zuerst entfernen
        
        listener = db.collection("recipes").addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ Fehler beim Abrufen der Rezepte: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            
            let recipes = snapshot.documents.compactMap { document in
                try? document.data(as: Recipe.self)
            }
            
            onChange(recipes)
        }
    }
    
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
        
        let ingredients = snapshot.documents.compactMap { document -> Ingredient? in
            try? document.data(as: Ingredient.self) // Firestore nutzt jetzt automatisch @DocumentID
        }
        
        print("✅ Zutaten extrahiert: \(ingredients.count)")
        return ingredients
    }
    
    // MARK: - 📤 Rezept erstellen
    func createRecipe(_ recipe: Recipe) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw RecipeError.noUserLoggedIn
        }
        
        let recipeRef = db.collection("recipes").document() // Firestore vergibt Rezept-ID
        var recipeData = try Firestore.Encoder().encode(recipe)
        recipeData["author"] = userID
        
        // 🔥 Entferne die Zutaten aus dem Hauptdokument, sie gehören in eine Unterkollektion!
        recipeData.removeValue(forKey: "ingredients")
        
        try await recipeRef.setData(recipeData)
        
        // 🔥 Zutaten als Unterkollektion speichern, Firestore vergibt die IDs automatisch
        for ingredient in recipe.ingredients ?? [] {
            let ingredientRef = recipeRef.collection("ingredients").document()
            let validatedQuantity = max(ingredient.quantity ?? 1.0, 0.01)
            try await ingredientRef.setData([
                "name": ingredient.name,
                "quantity": validatedQuantity
            ])
        }
        
        print("✅ Rezept erfolgreich gespeichert: \(recipe.name)")
    }
    
    // MARK: - ❌ Rezept aus Firestore löschen
    func deleteRecipe(_ recipeID: String) async throws {
        let recipeRef = db.collection("recipes").document(recipeID)

        // 🔥 Rezept löschen
        try await recipeRef.delete()

        print("✅ Firestore: Rezept erfolgreich gelöscht (ID: \(recipeID))")
    }
    
    // MARK: - Update Recipe
    
    func updateRecipe(_ recipe: Recipe) async throws {
        guard let recipeID = recipe.id else { throw RecipeError.noRecipeID }
        
        let recipeRef = db.collection("recipes").document(recipeID)
        
        var recipeData = try Firestore.Encoder().encode(recipe)
        
        try await recipeRef.updateData(recipeData)
        print("✅ Firestore: Rezept \(recipe.name) erfolgreich aktualisiert")
    }
    
    // MARK: - 🛒 Einkaufsliste verwalten
    func addIngredientToShoppingList(_ ingredient: Ingredient) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let shoppingListRef = db.collection("users").document(userID).collection("shoppingList")
        let documentRef = shoppingListRef.document(ingredient.name.lowercased())
        
        let snapshot = try await documentRef.getDocument()
        
        if snapshot.exists {
            // 🛠 Wenn die Zutat schon existiert: Menge aktualisieren
            let existingQuantity = snapshot.data()?["quantity"] as? Double ?? 0.0
            let newQuantity = existingQuantity + (ingredient.quantity ?? 0.0)
            
            try await documentRef.updateData(["quantity": newQuantity])
            
            print("🔄 Menge für \(ingredient.name) aktualisiert: \(existingQuantity) -> \(newQuantity)")
            
        } else {
            // 🆕 Falls die Zutat noch nicht existiert
            try await documentRef.setData([
                "name": ingredient.name,
                "quantity": ingredient.quantity ?? 0.0
            ])
            
            print("✅ Neue Zutat hinzugefügt: \(ingredient.name) (\(ingredient.quantity ?? 0.0))")
        }
    }
    
    func fetchShoppingList() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("shoppingList").getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let name = document["name"] as? String,
                  let quantity = document["quantity"] as? Double else {
                return nil
            }
            return Ingredient(id: document.documentID, name: name, quantity: quantity)
        }
    }
    
    func removeIngredientFromShoppingList(_ ingredientID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let shoppingListRef = db.collection("users").document(userID).collection("shoppingList").document(ingredientID)
        
        try await shoppingListRef.delete()
        print("✅ Erfolgreich gelöscht: \(ingredientID)")
    }
    
    // MARK: - 📦 Vorrat verwalten
    func addIngredientToInventory(_ ingredient: Ingredient) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }

        let inventoryRef = db.collection("users").document(userID).collection("inventory").document(ingredient.name.lowercased())

        let snapshot = try await inventoryRef.getDocument()
        
        if snapshot.exists {
            let existingQuantity = snapshot.data()?["quantity"] as? Double ?? 0.0
            let newQuantity = existingQuantity + (ingredient.quantity ?? 0.0)
            try await inventoryRef.updateData(["quantity": newQuantity])
            print("🔄 Menge für \(ingredient.name) aktualisiert: \(existingQuantity) -> \(newQuantity)")
        } else {
            try await inventoryRef.setData([
                "name": ingredient.name,
                "quantity": ingredient.quantity ?? 0.0
            ])
            print("✅ Neue Zutat hinzugefügt: \(ingredient.name)")
        }
    }
    
    func fetchInventory() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }

        let snapshot = try await db.collection("users").document(userID).collection("inventory").getDocuments()

        return snapshot.documents.compactMap { document in
            guard let name = document["name"] as? String,
                  let quantity = document["quantity"] as? Double else {
                return nil
            }
            return Ingredient(id: document.documentID, name: name, quantity: quantity)
        }
    }
    
    func removeIngredientFromInventory(_ ingredientName: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let inventoryRef = db.collection("users").document(userID).collection("inventory").document(ingredientName.lowercased())
        try await inventoryRef.delete()
        print("🗑 Zutat \(ingredientName) entfernt")
    }
    
    func updateIngredientInInventory(_ ingredientName: String, newQuantity: Double) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }

        let inventoryRef = db.collection("users").document(userID).collection("inventory").document(ingredientName.lowercased())

        if newQuantity > 0 {
            try await inventoryRef.updateData(["quantity": newQuantity])
            print("🔄 Menge für \(ingredientName) aktualisiert auf \(newQuantity)")
        } else {
            try await inventoryRef.delete()
            print("🗑 Zutat \(ingredientName) entfernt, da Menge = 0")
        }
    }
    
    
    // MARK: - 🔥 Fehlerhandling
    enum RecipeError: LocalizedError {
        case noUserLoggedIn
        case decodingFailed(reason: String)
        case noRecipeID
        
        var errorDescription: String? {
            switch self {
            case .noUserLoggedIn:
                return "Kein Benutzer eingeloggt."
            case .decodingFailed(let reason):
                return "Fehler beim Dekodieren: \(reason)"
            case .noRecipeID:
                return "Kein Rezept-ID angegeben."
            }
        }
    }
}

