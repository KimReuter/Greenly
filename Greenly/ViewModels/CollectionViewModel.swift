//
//  CollectionViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
final class CollectionViewModel {
    
    private let collectionManager = CollectionManager()
    private let recipeManager = RecipeManager()
    
    var collections: [RecipeCollection] = []
    var collectionRecipes: [String: [Recipe]] = [:] // 🔥 Map: Sammlung-ID → Liste der geladenen Rezepte
    var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    // 📥 Sammlungen abrufen
    func fetchCollections() async {
        do {
            collections = try await collectionManager.fetchCollections()
            print("✅ Sammlungen geladen: \(collections.count)")
        } catch {
            print("❌ Fehler beim Laden der Sammlungen: \(error.localizedDescription)")
        }
    }
    
    // ➕ Neue Sammlung erstellen
    func createCollection(name: String) async {
        do {
            try await collectionManager.createCollection(name: name)
            await fetchCollections() // Aktualisieren
        } catch {
            print("❌ Fehler beim Erstellen der Sammlung: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // 📥 Rezepte für eine Sammlung abrufen
    func fetchRecipesForCollection(collection: RecipeCollection) async {
        guard let collectionID = collection.id else {
            print("❌ Fehler: Sammlung hat keine ID!")
            return
        }
        
        print("📥 Lade Rezepte für Sammlung: \(collection.name) mit IDs: \(collection.recipeIDs)")

        do {
            let loadedRecipes = try await recipeManager.fetchRecipesByIDs(collection.recipeIDs)
            print("✅ Rezepte geladen: \(loadedRecipes.count)")

            // 🔥 UI sofort aktualisieren
            collectionRecipes[collectionID] = loadedRecipes
            
            print("✅ Sammlung erfolgreich aktualisiert! UI sollte sich jetzt sofort aktualisieren.")
        } catch {
            print("❌ Fehler beim Laden der Rezepte: \(error.localizedDescription)")
        }
    }
    
    // 📌 Rezept(e) zur Sammlung hinzufügen
    func addRecipesToCollection(collectionID: String, recipeIDs: [String]) async {
        do {
            print("📢 Starte das Hinzufügen von Rezepten zur Sammlung: \(collectionID)")

            // 🔥 Rezepte in Firestore speichern
            for recipeID in recipeIDs {
                try await collectionManager.addRecipeToCollection(collectionID: collectionID, recipeID: recipeID)
                print("✅ Rezept \(recipeID) erfolgreich zu Firestore hinzugefügt")
            }

            // ✅ Rezept-IDs direkt in der Sammlung aktualisieren (verhindert UI-Flackern)
            if let index = collections.firstIndex(where: { $0.id == collectionID }) {
                collections[index].recipeIDs.append(contentsOf: recipeIDs)
                print("✅ Rezept-IDs zur Sammlung hinzugefügt: \(collections[index].recipeIDs)")

                // 🔥 Neue Rezepte direkt aus Firestore holen
                let newRecipes = try await recipeManager.fetchRecipesByIDs(recipeIDs)
                print("✅ Neue Rezepte aus Firestore geladen: \(newRecipes.map { $0.name })")

                // ✅ UI sofort aktualisieren (keine alten Werte überschreiben!)
                collectionRecipes[collectionID, default: []] += newRecipes

                print("✅ Sammlung erfolgreich aktualisiert! UI sollte sich jetzt sofort aktualisieren.")

                // 🔄 🔥 **Neuen Fix: Warten, bevor Firestore erneut abgefragt wird!**
                try await Task.sleep(nanoseconds: 1_000_500_000) // 1 Sekunde warten

                // 🔥 Jetzt Firestore neu abrufen
                await fetchRecipesForCollection(collection: collections[index])
            } else {
                print("❌ Fehler: Sammlung nicht gefunden!")
            }

        } catch {
            print("❌ Fehler beim Hinzufügen von Rezepten zur Sammlung: \(error.localizedDescription)")
        }
    }
    
    func removeRecipeFromCollection(collectionID: String, recipeID: String) async {
        do {
            print("🗑 Entferne Rezept \(recipeID) aus Sammlung \(collectionID)")

            // Firestore Update
            try await collectionManager.removeRecipeFromCollection(collectionID: collectionID, recipeID: recipeID)
            print("✅ Rezept erfolgreich aus Firestore entfernt")

            // UI Update: Rezept aus der lokalen Sammlung entfernen
            if let index = collections.firstIndex(where: { $0.id == collectionID }) {
                collections[index].recipeIDs.removeAll { $0 == recipeID }
                collectionRecipes[collectionID]?.removeAll { $0.id == recipeID }
                print("✅ UI aktualisiert, Rezept aus Sammlung entfernt")
            }

        } catch {
            print("❌ Fehler beim Entfernen des Rezepts aus der Sammlung: \(error.localizedDescription)")
        }
    }
    
}
