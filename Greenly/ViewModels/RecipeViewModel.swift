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
    
    private let recipeManager = RecipeManager()
    private let imageRepository: ImageRepository
    
    var selectedImageItem: PhotosPickerItem?
    var selectedImage: Image?
    var selectedImageData: Data?
    var uploadedImageRef: ImageRef?
    
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
    
    // MARK: - 📡 Snapshot Listener für Rezepte
    func observeRecipes() {
        do {
            try recipeManager.observeRecipes { [weak self] newRecipes in
                guard let self = self else { return }
                print("🔥 observeRecipes wurde aufgerufen. Anzahl neue Rezepte: \(newRecipes.count)")
                Task {
                    self.recipes = newRecipes
                    await self.applyFilters()
                    print("✅ Live-Update: \(newRecipes.count) Rezepte geladen")
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
        
        print("📥 Lade Zutaten für Rezept ID: \(recipeID)")
        
        do {
            let loadedIngredients = try await recipeManager.fetchIngredients(forRecipeID: recipeID)
            print("✅ Firestore hat Zutaten zurückgegeben: \(loadedIngredients.count)")
            
            if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
                recipes[index].ingredients = loadedIngredients
                print("✅ Zutaten für \(recipes[index].name) gespeichert: \(recipes[index].ingredients?.count ?? 0)")
            }
            
            // 🔥 Erzwingen, dass SwiftUI das ViewModel erkennt:
            recipes = recipes.map { r in
                if r.id == recipeID {
                    var updatedRecipe = r
                    updatedRecipe.ingredients = loadedIngredients
                    return updatedRecipe
                }
                return r
            }
            
            print("✅ Zutaten nach Laden: \(recipes.first(where: { $0.id == recipeID })?.ingredients?.count ?? 0)")
            
        } catch {
            print("❌ Fehler beim Laden der Zutaten: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    // MARK: - 📤 Rezept erstellen
    func createRecipe(_ recipe: Recipe) async throws {
        try await recipeManager.createRecipe(recipe)
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
            ingredientToAdd.quantity = missingQuantity // ✅ Setze nur die fehlende Menge
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
            // Falls die Zutat bereits im Inventory existiert → Menge addieren
            let existingQuantity = inventory.first { $0.name.lowercased() == ingredient.name.lowercased() }?.quantity ?? 0.0
            let newQuantity = existingQuantity + (ingredient.quantity ?? 0.0)
            
            try await recipeManager.addIngredientToInventory(Ingredient(name: ingredient.name, quantity: newQuantity))
            try await recipeManager.removeIngredientFromShoppingList(ingredient.name)
            
            print("✅ \(ingredient.name) aus Einkaufsliste ins Inventory verschoben")
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
    
    func uploadImage() async {
        guard let selectedImageData else {
            errorMessage = "❌ Kein Bild ausgewählt"
            print("❌ Kein Bild vorhanden zum Hochladen")
            return
        }

        print("🚀 Starte Upload zu Imgur...") // Debugging-Print

        do {
            uploadedImageRef = try await imageRepository.uploadImage(data: selectedImageData)
            print("✅ Bild erfolgreich hochgeladen: \(uploadedImageRef?.url ?? "Keine URL erhalten")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Fehler beim Hochladen des Bildes: \(error.localizedDescription)")
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
    
    // MARK: - 🛠 ViewModel initialisieren
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
        observeRecipes()
    }
}
