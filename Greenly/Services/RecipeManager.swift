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
            print("📄 Firestore-Dokument: \(document.data())") // 🔥 Debugging: Zeigt alle Daten des Rezepts

            do {
                var recipe = try document.data(as: Recipe.self)
                recipe.id = document.documentID // 🔥 WICHTIG: Firestore-Dokument-ID setzen
                
                // 🔥 Falls `category` fehlt, setzen wir ein leeres Array
                if document["category"] == nil {
                    recipe.category = []
                }

                // 🔥 Falls `preparationSteps` fehlt, setzen wir nil (weil jetzt optional)
                if document["preparationSteps"] == nil {
                    recipe.preparationSteps = nil
                }

                // 🔥 Prüfen, ob Zutaten als Array gespeichert sind (alte Struktur)
                if let ingredientArray = document["ingredients"] as? [[String: Any]] {
                    print("⚠️ Alte Zutatenstruktur erkannt, konvertiere...")

                    let ingredients = ingredientArray.compactMap { dict -> Ingredient? in
                        guard let name = dict["name"] as? String,
                              let quantity = dict["quantity"] as? Double else {
                            return nil
                        }
                        let unitRawValue = dict["unit"] as? String
                        let unit = unitRawValue != nil ? MeasurementUnit(rawValue: unitRawValue!) : .gram

                        return Ingredient(name: name, quantity: quantity, unit: unit)
                    }
                    recipe.ingredients = ingredients
                } else {
                    // 🔥 Zutaten aus Unterkollektion abrufen
                    let ingredients = try await fetchIngredients(forRecipeID: document.documentID)
                    recipe.ingredients = ingredients
                }

                recipes.append(recipe)
            } catch {
                print("❌ Fehler beim Dekodieren des Rezepts mit ID: \(document.documentID)")
                print("🚨 Firestore-Daten: \(document.data())") // 🔥 Zeigt das fehlerhafte Rezept an
                throw RecipeError.decodingFailed(reason: error.localizedDescription)
            }
        }

        print("📥 `fetchRecipes()` hat \(recipes.count) Rezepte geladen.")
        return recipes
    }
    // MARK: - Rezepte für Sammlung laden
    
    func fetchRecipesForCollection(recipeIDs: [String]) async throws -> [Recipe] {
        guard !recipeIDs.isEmpty else { return [] } // 🔍 Falls keine Rezepte, nichts abrufen
        
        let snapshot = try await db.collection("recipes")
            .whereField(FieldPath.documentID(), in: recipeIDs) // 🔥 Alle Rezepte in einem Query abrufen!
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }
    
    func fetchRecipesByIDs(_ recipeIDs: [String]) async throws -> [Recipe] {
        guard !recipeIDs.isEmpty else { return [] }
        
        var recipes: [Recipe] = []
        
        for id in recipeIDs {
            let docRef = db.collection("recipes").document(id)
            
            let document = try await docRef.getDocument()
            if let recipe = try? document.data(as: Recipe.self) {
                recipes.append(recipe)
            } else {
                print("⚠️ Konnte Rezept nicht dekodieren: \(id)")
            }
        }
        
        print("🔥 Firestore: \(recipes.count) Rezepte erfolgreich geladen")
        return recipes
    }
    
    
    
    // MARK: - 📥 Zutaten abrufen
    func fetchIngredients(forRecipeID recipeID: String) async throws -> [Ingredient] {
        let ingredientsRef = db.collection("recipes").document(recipeID).collection("ingredients")

        print("📂 Firestore Collection Path: recipes/\(recipeID)/ingredients")

        let snapshot = try await ingredientsRef.getDocuments()

        print("🔥 Firestore Snapshot Größe: \(snapshot.documents.count)")

        let ingredients = snapshot.documents.compactMap { document -> Ingredient? in
            let name = document["name"] as? String
            let quantity = document["quantity"] as? Double
            let unitRawValue = document["unit"] as? String

            print("🧐 Zutat aus Firestore: Name=\(name ?? "Fehlt"), Menge=\(quantity ?? 0.0), Einheit=\(unitRawValue ?? "Fehlt")")

            // Falls `unit` nicht existiert, setzen wir `.gram` als Standardwert
            let unit = unitRawValue != nil ? MeasurementUnit(rawValue: unitRawValue!) : .gram

            guard let name = name, let quantity = quantity else {
                print("⚠️ Fehler: Name oder Menge fehlt, Zutat wird ignoriert")
                return nil
            }

            return Ingredient(id: document.documentID, name: name, quantity: quantity, unit: unit)
        }

        print("✅ Zutaten extrahiert: \(ingredients.count)")
        return ingredients
    }
    
    // MARK: - 📤 Rezept erstellen
    func createRecipe(_ recipe: Recipe) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw RecipeError.noUserLoggedIn
        }

        let recipeRef = db.collection("recipes").document()
        var recipeData = try Firestore.Encoder().encode(recipe)
        recipeData["author"] = userID

        recipeData.removeValue(forKey: "ingredients") // 🔥 Zutaten separat speichern
        recipeData.removeValue(forKey: "preparationSteps") // 🔥 Schritte separat speichern

        try await recipeRef.setData(recipeData)

        // 🔥 Zutaten speichern
        for ingredient in recipe.ingredients ?? [] {
            let ingredientRef = recipeRef.collection("ingredients").document()
            try await ingredientRef.setData([
                "name": ingredient.name,
                "quantity": ingredient.quantity ?? 0.0,
                "unit": ingredient.unit?.rawValue ?? MeasurementUnit.gram.rawValue
            ])
        }
        // 🔥 Zubereitungsschritte speichern (nur wenn vorhanden)
        if let steps = recipe.preparationSteps {
            for (index, step) in steps.enumerated() {
                let stepRef = recipeRef.collection("preparationSteps").document("\(index)")
                try await stepRef.setData(["step": step.rawValue])
            }
        }
        
        print("✅ Rezept mit \(recipe.preparationSteps?.count ?? 0) Schritten gespeichert!")

    }
    
    // MARK: - Zubereitungsschritte abrufen & ändern
    
    func fetchPreparationSteps(forRecipeID recipeID: String) async throws -> [PreparationStepType] {
        let stepsRef = db.collection("recipes").document(recipeID).collection("preparationSteps")
        
        let snapshot = try await stepsRef.getDocuments()
        let steps = snapshot.documents.compactMap { doc in
            PreparationStepType(rawValue: doc["step"] as? String ?? "")
        }
        
        print("✅ \(steps.count) Zubereitungsschritte geladen")
        return steps
    }
    
    func updatePreparationSteps(forRecipeID recipeID: String, newSteps: [PreparationStepType]) async throws {
        let recipeRef = db.collection("recipes").document(recipeID)
        let stepsRef = recipeRef.collection("preparationSteps")

        // 🔥 Bestehende Schritte löschen
        let snapshot = try await stepsRef.getDocuments()
        await withTaskGroup(of: Void.self) { group in
            for doc in snapshot.documents {
                group.addTask {
                    do {
                        try await doc.reference.delete()
                    } catch {
                        print("❌ Fehler beim Löschen eines Schritts: \(error.localizedDescription)")
                    }
                }
            }
        }

        // 🔥 Neue Schritte speichern
        await withTaskGroup(of: Void.self) { group in
            for (index, step) in newSteps.enumerated() {
                group.addTask {
                    do {
                        let stepRef = stepsRef.document("\(index)")
                        try await stepRef.setData(["step": step.rawValue])
                    } catch {
                        print("❌ Fehler beim Speichern eines Schritts: \(error.localizedDescription)")
                    }
                }
            }
        }

        print("✅ Zubereitungsschritte für Rezept-ID \(recipeID) erfolgreich gespeichert: \(newSteps.count) Schritte")
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
        
        let recipeData = try Firestore.Encoder().encode(recipe)
        
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
                "quantity": ingredient.quantity ?? 0.0,
                "unit": ingredient.unit?.rawValue ?? MeasurementUnit.gram.rawValue
            ])
            
            print("✅ Neue Zutat hinzugefügt: \(ingredient.name) (\(ingredient.quantity ?? 0.0))")
        }
    }
    
    func fetchShoppingList() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("shoppingList").getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let name = document["name"] as? String,
                  let quantity = document["quantity"] as? Double,
                  let unitRawValue = document["unit"] as? String,
                  let unit = unitRawValue != nil ? MeasurementUnit(rawValue: unitRawValue) : .gram else { return nil }
            
            return Ingredient(id: document.documentID, name: name, quantity: quantity, unit: unit)
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
                "quantity": ingredient.quantity ?? 0.0,
                "unit": ingredient.unit?.rawValue ?? MeasurementUnit.gram.rawValue
            ])
            print("✅ Neue Zutat hinzugefügt: \(ingredient.name)")
        }
    }
    
    func fetchInventory() async throws -> [Ingredient] {
        guard let userID = Auth.auth().currentUser?.uid else { throw RecipeError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("inventory").getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let name = document["name"] as? String,
                  let quantity = document["quantity"] as? Double,
                  let unitRawValue = document["unit"] as? String,
                  let unit = unitRawValue != nil ? MeasurementUnit(rawValue: unitRawValue) : .gram else { return nil }
            
            return Ingredient(id: document.documentID, name: name, quantity: quantity, unit: unit)
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

