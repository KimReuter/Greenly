//
//  RecipeViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import SwiftUI

@Observable
final class RecipeViewModel {
    
    var recipes: [Recipe] = []
    var filteredRecipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var inventory: [Ingredient] = []
    var shoppingList: [Ingredient] = []
    var checkedItems: Set<String> = []
    var errorMessage: String?
    
    var searchQuery: String = "" // Suchtext (Name oder Beschreibung)
    var selectedCategory: Set<RecipeCategory> = [] // ✅ Set für Filter
    var selectedIngredient: String = "" // Gesuchte Zutat
    var selectedUnit: MeasurementUnit = .gram
    
    private let recipeManager = RecipeManager()
    private let imageRepository: ImageRepository
    
    var selectedImageItem: PhotosPickerItem?
    var selectedImage: Image?
    var selectedImageData: Data?
    var uploadedImageRef: ImageRef?
    
    var preparationSteps: [PreparationStepType] = []
    
    var uploadedImageURL: URL? {
        guard let imageRef = uploadedImageRef else { return nil }
        return URL(string: imageRef.url)
    }
    
    var currentFilter: FilterType? {
        if !searchQuery.isEmpty { return .searchQuery }
        else if !selectedCategory.isEmpty { return .category }
        else if !selectedIngredient.isEmpty { return .ingredient }
        return nil
    }
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private var ingredientsCache: [String: [Ingredient]] = [:] // 🔥 Cache für Zutaten
    
    // MARK: - 📡 Snapshot Listener für Rezepte
    func observeRecipes() {
        do {
            try recipeManager.observeRecipes { [weak self] newRecipes in
                guard let self = self else { return }
                print("🔥 observeRecipes wurde aufgerufen. Anzahl neue Rezepte: \(newRecipes.count)")
                Task {
                    self.recipes = newRecipes
                    print("📥 Rezepte aus Firestore:")
                    for recipe in newRecipes {
                        print(" - \(recipe.name) (ID: \(recipe.id ?? "Keine ID"))")
                    }
                    await self.applyFilters()
                    print("✅ Live-Update: \(self.recipes.count) Rezepte geladen")
                }
            }
        } catch {
            print("❌ Fehler beim Starten des Snapshot Listeners: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - 🔍 Filter anwenden
    func applyFilters() async {
        print("🔍 Filter wird angewendet...")
        print("🔍 Rezepte vor dem Filtern: \(recipes.count)")
        
        filteredRecipes = recipes.filter { recipe in
            let matchesSearchText = searchQuery.isEmpty ||
            recipe.name.localizedCaseInsensitiveContains(searchQuery) ||
            recipe.description.localizedCaseInsensitiveContains(searchQuery)
            
            let matchesCategory = selectedCategory.isEmpty ||
            recipe.category.contains { selectedCategory.contains($0) }
            
            let matchesIngredient = selectedIngredient.isEmpty ||
            (recipe.ingredients?.contains { $0.name.localizedCaseInsensitiveContains(selectedIngredient) } ?? false)
            
            return matchesSearchText && matchesCategory && matchesIngredient
        }
        
        print("🔥 Gefilterte Rezepte: \(filteredRecipes.count)")
    }
    
    // MARK: - ❌ Filter zurücksetzen
    func clearFilter(_ filterType: FilterType) async {
        print("🔄 Lösche Filter: \(filterType)")
        
        switch filterType {
        case .searchQuery:
            searchQuery = ""
            
        case .category:
            // ✅ Entfernt nur eine Kategorie, nicht alle!
            if let firstCategory = selectedCategory.first {
                selectedCategory.remove(firstCategory)
            }
            
        case .ingredient:
            selectedIngredient = ""
        }
        
        await applyFilters() // 🔥 Aktualisiere Rezepte mit den verbleibenden Filtern
        print("✅ Filter nach Löschen angewendet: \(filteredRecipes.count) Rezepte übrig")
    }
    
    // MARK: - 📥 Rezepte abrufen
    func fetchRecipes() async {
        do {
            let loadedRecipes = try await recipeManager.fetchRecipes()
            recipes = loadedRecipes
            print("🔥 Rezepte geladen: \(recipes.count)")
            await applyFilters()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Fehler beim Laden der Rezepte: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 📥 Zutaten für ein Rezept abrufen
    func fetchIngredients(for recipe: Recipe) async {
        guard let recipeID = recipe.id else { return }
        
        do {
            let loadedIngredients = try await recipeManager.fetchIngredients(forRecipeID: recipeID)
            
            for ingredient in loadedIngredients {
                print("🥄 Geladene Zutat: \(ingredient.name), Menge: \(ingredient.quantity ?? 0.0) \(ingredient.unit?.name ?? "Gramm")")
            }
            
            if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
                recipes[index].ingredients = loadedIngredients
            }
        } catch {
            print("❌ Fehler beim Laden der Zutaten: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 📤 Rezept erstellen
    func createRecipe(_ recipe: Recipe) async throws {
        var updatedRecipe = recipe
        
        // 🛠 Lokale Kopie des Arrays erstellen
        var updatedIngredients = updatedRecipe.ingredients ?? []
        
        for i in 0..<updatedIngredients.count {
            updatedIngredients[i].unit = updatedIngredients[i].unit ?? .gram
        }
        
        // 🔄 Aktualisierte Zutaten in `updatedRecipe` speichern
        updatedRecipe.ingredients = updatedIngredients
        
        try await recipeManager.createRecipe(updatedRecipe)
        print("✅ Rezept erstellt mit Zutaten: \(updatedRecipe.ingredients?.count ?? 0)")
    }
    
    
    
    // MARK: - ❌ Rezept löschen
    func deleteRecipe(_ recipe: Recipe) async {
        guard let recipeID = recipe.id else {
            print("❌ Fehler: Rezept hat keine ID!")
            return
        }
        
        do {
            try await recipeManager.deleteRecipe(recipeID)
            
            // 🔄 Live-Update: Rezept aus Liste entfernen
            if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
                recipes.remove(at: index)
            }
            
            print("✅ Rezept gelöscht: \(recipe.name)")
        } catch {
            errorMessage = "❌ Fehler beim Löschen des Rezepts: \(error.localizedDescription)"
            print(errorMessage!)
        }
    }
    
    // MARK: - ✏️ Rezept aktualisieren
    func updateRecipe(_ updatedRecipe: Recipe, newImageData: Data?) async {
        do {
            var recipeToUpdate = updatedRecipe
            
            // 🛠 Lokale Kopie der Zutaten erstellen
            var updatedIngredients = recipeToUpdate.ingredients ?? []
            
            for i in 0..<updatedIngredients.count {
                updatedIngredients[i].unit = updatedIngredients[i].unit ?? .gram
            }
            
            // 🔄 Aktualisierte Zutaten in `recipeToUpdate` speichern
            recipeToUpdate.ingredients = updatedIngredients
            
            try await recipeManager.updateRecipe(recipeToUpdate)
            print("✅ Rezept erfolgreich aktualisiert: \(recipeToUpdate.name)")
        } catch {
            print("❌ Fehler beim Aktualisieren: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 📥 Einkaufsliste abrufen
    func fetchShoppingList() async {
        do {
            shoppingList = try await recipeManager.fetchShoppingList()
            print("🛒 Einkaufsliste geladen: \(shoppingList.count)")
        } catch {
            print("❌ Fehler beim Laden der Einkaufsliste: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ➕ Zutat zur Einkaufsliste hinzufügen
    func addToShoppingList(_ ingredient: Ingredient, missingQuantity: Double) async {
        do {
            var ingredientToAdd = ingredient
            ingredientToAdd.quantity = missingQuantity
            ingredientToAdd.unit = ingredient.unit // 🔥 `unit` beibehalten
            
            try await recipeManager.addIngredientToShoppingList(ingredientToAdd)
            await fetchShoppingList()
        } catch {
            print("❌ Fehler beim Hinzufügen zur Einkaufsliste: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 🗑 Zutat aus Einkaufsliste entfernen
    func removeFromShoppingList(_ ingredient: Ingredient) async {
        print("🗑 Starte Entfernen von \(ingredient.name) (ID: \(ingredient.id ?? "keine ID")) aus der Einkaufsliste...")
        guard let ingredientID = ingredient.id else {
            print("❌ Fehler: Keine ID für \(ingredient.name) gefunden!")
            return
        }
        
        do {
            print("🛒 Firestore: Entferne \(ingredient.name) mit ID \(ingredientID) aus ShoppingList")
            
            // ✅ 1. Entferne die Zutat aus Firestore
            try await recipeManager.removeIngredientFromShoppingList(ingredientID)
            
            print("✅ Erfolgreich gelöscht: \(ingredient.name)")
            
            // ✅ 2. Warte kurz, um Firestore zu aktualisieren
            try await Task.sleep(nanoseconds: 300_000_000) // 🔄 0.3 Sek
            
            // ✅ 3. Aktualisiere die Einkaufsliste
            await fetchShoppingList()
            
        } catch {
            print("❌ Fehler beim Entfernen von \(ingredient.name) aus der Einkaufsliste: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 📦 Vorrat abrufen
    func fetchInventory() async {
        do {
            inventory = try await recipeManager.fetchInventory()
            print("📦 Vorrat geladen: \(inventory.count)")
        } catch {
            print("❌ Fehler beim Laden des Vorrats: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ➕ Zutat zum Vorrat hinzufügen
    func addToInventory(_ ingredient: Ingredient, additionalQuantity: Double) async {
        do {
            var updatedIngredient = ingredient
            updatedIngredient.quantity = additionalQuantity // ✅ Zusätzliche Menge hinzufügen
            try await recipeManager.addIngredientToInventory(updatedIngredient)
            await fetchInventory()
        } catch {
            print("❌ Fehler beim Hinzufügen zum Vorrat: \(error.localizedDescription)")
        }
    }
    
    func handleIngredientSelection(_ ingredient: Ingredient) {
        Task {
            checkedItems.insert(ingredient.name) // ✅ Haken setzen mit Animation
            
            try? await Task.sleep(nanoseconds: 700_000_000) // ⏳ Kürzere Wartezeit
            await moveToInventory(ingredient) // ➡️ Zutat in Inventar verschieben
            
            try? await Task.sleep(nanoseconds: 300_000_000) // ⏳ Extra Verzögerung
            checkedItems.remove(ingredient.name) // 🔄 Haken entfernen mit Animation
            
            await removeFromShoppingList(ingredient) // 🗑 Zutat aus der Liste entfernen
        }
    }
    
    // MARK: _ Aus Vorrat entfernen
    
    func removeFromInventory(_ ingredientName: String) async {
        do {
            try await recipeManager.removeIngredientFromInventory(ingredientName)
        } catch {
            print("❌ Fehler beim Entfernen von \(ingredientName) aus dem Inventory: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Zutaten aus Inventory entfernen bei Zubereitung
    
    func consumeIngredientsForRecipe(_ recipe: Recipe) async {
        for ingredient in recipe.ingredients ?? [] {
            do {
                let availableQuantity = inventory.first(where: { $0.name.lowercased() == ingredient.name.lowercased() })?.quantity ?? 0.0
                let requiredQuantity = ingredient.quantity ?? 0.0
                
                if availableQuantity >= requiredQuantity {
                    // ✅ Falls genug da ist → nur reduzieren
                    let newQuantity = availableQuantity - requiredQuantity
                    try await recipeManager.updateIngredientInInventory(ingredient.name, newQuantity: newQuantity)
                    print("🍽 Verbrauch: \(ingredient.name) reduziert auf \(newQuantity)")
                    
                } else {
                    // ❌ Falls zu wenig da ist → komplett entfernen
                    try await recipeManager.removeIngredientFromInventory(ingredient.name)
                    print("🗑 \(ingredient.name) entfernt, da nicht genug vorhanden")
                }
            } catch {
                print("❌ Fehler beim Verbrauch von \(ingredient.name): \(error.localizedDescription)")
            }
        }
        
        await fetchInventory() // 🔄 Aktualisiere nach Verbrauch
    }
    
    // MARK: - Zutaten von Einkaufsliste in Inventory schieben
    
    func moveToInventory(_ ingredient: Ingredient) async {
        do {
            // 🔍 Falls die Zutat bereits im Inventar existiert → Menge und Einheit beibehalten
            let existingIngredient = inventory.first { $0.name.lowercased() == ingredient.name.lowercased() }
            let existingQuantity = existingIngredient?.quantity ?? 0.0
            let newQuantity = existingQuantity + (ingredient.quantity ?? 0.0)
            
            // 🔥 Einheit beibehalten oder Standard setzen
            let unit = ingredient.unit
            
            // 📥 Zutat ins Inventar hinzufügen
            try await recipeManager.addIngredientToInventory(Ingredient(name: ingredient.name, quantity: newQuantity, unit: unit))
            
            // 🗑 Zutat aus der Einkaufsliste entfernen
            try await recipeManager.removeIngredientFromShoppingList(ingredient.name)
            
            print("✅ \(ingredient.name) aus Einkaufsliste ins Inventar verschoben")
            await fetchInventory()
            await fetchShoppingList() // 🔄 Aktualisieren nach Bewegung
        } catch {
            print("❌ Fehler beim Verschieben von \(ingredient.name) ins Inventory: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 🛒 Zutaten für Rezept zur Einkaufsliste hinzufügen
    func checkAndUpdateShoppingList(for recipe: Recipe) async {
        await fetchInventory()
        
        var missingIngredients: [Ingredient] = []
        
        for ingredient in recipe.ingredients ?? [] {
            let availableQuantity = inventory.first { $0.name.lowercased() == ingredient.name.lowercased() }?.quantity ?? 0.0
            let requiredQuantity = ingredient.quantity ?? 0.0
            
            print("🔍 Prüfe Zutat: \(ingredient.name)")
            print("   - Verfügbar: \(availableQuantity)")
            print("   - Benötigt: \(requiredQuantity)")
            
            if requiredQuantity > availableQuantity { // ❗️ Überprüfe, ob genug Vorrat vorhanden ist
                let missingQuantity = requiredQuantity - availableQuantity
                var missingIngredient = ingredient
                missingIngredient.quantity = missingQuantity // ✅ Speichere nur die fehlende Menge
                missingIngredients.append(missingIngredient)
                
                print("⚠️ Fehlende Menge: \(missingQuantity), wird zur Einkaufsliste hinzugefügt!")
            } else {
                print("✅ Genug vorhanden, wird NICHT zur Einkaufsliste hinzugefügt.")
            }
        }
        
        for ingredient in missingIngredients {
            do {
                try await recipeManager.addIngredientToShoppingList(ingredient)
                print("✅ Erfolgreich zur Einkaufsliste hinzugefügt: \(ingredient.name)")
            } catch {
                print("❌ Fehler beim Hinzufügen zur Einkaufsliste: \(error.localizedDescription)")
            }
        }
        
        await fetchShoppingList() // 🔥 Einkaufsliste neu abrufen
    }
    
    // MARK: - Bild Upload mit Imgur
    
    func fetchImageFromStorage() {
        Task {
            do {
                selectedImage = try await selectedImageItem?.loadTransferable(type: Image.self)
                selectedImageData = try await selectedImageItem?.loadTransferable(type: Data.self)
                print("✅ Bild aus der Galerie geladen") // Debugging
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadImage(data: Data) async throws -> String {
        print("🚀 Starte Upload zu Imgur...")
        
        do {
            let uploadedImageRef = try await imageRepository.uploadImage(data: data)
            print("✅ Bild erfolgreich hochgeladen: \(uploadedImageRef.url)")
            return uploadedImageRef.url
        } catch {
            print("❌ Fehler beim Hochladen des Bildes: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteImage() async {
        guard let uploadedImageRef else {
            errorMessage = "Kein hochgeladenes Bild zum Löschen"
            return
        }
        do {
            try await imageRepository.deleteImage(uploadedImageRef)
            self.uploadedImageRef = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Zubereitungsschritte laden & ändern
    
    func fetchPreparationSteps(for recipe: Recipe) async {
        guard let recipeID = recipe.id else {
            print("⚠️ Kein Rezept-ID gefunden, kann Schritte nicht laden.")
            return
        }
        
        do {
            let steps = try await recipeManager.fetchPreparationSteps(forRecipeID: recipeID)
            await MainActor.run {
                self.preparationSteps = steps
            }
            print("✅ Zubereitungsschritte für '\(recipe.name)' geladen: \(steps.count) Schritte")
        } catch {
            print("❌ Fehler beim Laden der Zubereitungsschritte: \(error.localizedDescription)")
        }
    }
    
    func updatePreparationSteps(for recipe: Recipe, newSteps: [PreparationStepType]) async {
        guard let recipeID = recipe.id else {
            print("⚠️ Kein Rezept-ID gefunden, kann Schritte nicht speichern.")
            return
        }
        
        do {
            try await recipeManager.updatePreparationSteps(forRecipeID: recipeID, newSteps: newSteps)
            await MainActor.run {
                self.preparationSteps = newSteps
            }
            print("✅ Zubereitungsschritte für '\(recipe.name)' aktualisiert: \(newSteps.count) Schritte")
        } catch {
            print("❌ Fehler beim Speichern der Zubereitungsschritte: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 🛠 ViewModel initialisieren
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
        observeRecipes()
    }
}
