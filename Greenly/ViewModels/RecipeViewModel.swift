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
    var filteredRecipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var inventory: [Ingredient] = []
    var shoppingList: [Ingredient] = []
    var errorMessage: String?
    
    var searchQuery: String = "" // Suchtext (Name oder Beschreibung)
    var selectedCategory: Set<RecipeCategory> = [] // ✅ Set für Filter
    var selectedIngredient: String = "" // Gesuchte Zutat

    private let recipeManager = RecipeManager()
    
    var currentFilter: FilterType? {
        if !searchQuery.isEmpty {
            return .searchQuery
        } else if !selectedCategory.isEmpty {
            return .category
        } else if !selectedIngredient.isEmpty {
            return .ingredient
        }
        return nil
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
                print("✅ Zutaten nach Laden: \(recipes[index].ingredients?.count ?? 0)")
            }

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
    func addToShoppingList(_ ingredient: Ingredient) async {
        do {
            try await recipeManager.addIngredientToShoppingList(ingredient)
            await fetchShoppingList()
        } catch {
            print("❌ Fehler beim Hinzufügen zur Einkaufsliste: \(error.localizedDescription)")
        }
    }

    // MARK: - 🗑 Zutat aus Einkaufsliste entfernen
    func removeFromShoppingList(_ ingredientID: String) async {
        do {
            try await recipeManager.removeIngredientFromShoppingList(ingredientID)
            await fetchShoppingList()
        } catch {
            print("❌ Fehler beim Entfernen aus der Einkaufsliste: \(error.localizedDescription)")
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
    func addToInventory(_ ingredient: Ingredient) async {
        do {
            try await recipeManager.addIngredientToInventory(ingredient)
            await fetchInventory()
        } catch {
            print("❌ Fehler beim Hinzufügen zum Vorrat: \(error.localizedDescription)")
        }
    }

    // MARK: - 🛒 Zutaten für Rezept zur Einkaufsliste hinzufügen
    func checkAndUpdateShoppingList(for recipe: Recipe) async {
        await fetchInventory()

        var missingIngredients: [Ingredient] = []

        for ingredient in recipe.ingredients ?? [] {
            if !inventory.contains(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
                missingIngredients.append(ingredient)
            }
        }

        for ingredient in missingIngredients {
            await addToShoppingList(ingredient)
        }
    }

    // MARK: - 🛠 ViewModel initialisieren
    init() {
        Task {
            await fetchRecipes()
        }
    }
}
