//
//  CollectionManager.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@Observable
final class CollectionManager {
    
    private let db = Firestore.firestore()
    
    // ✅ Sammlungen für aktuellen User abrufen
    func fetchCollections() async throws -> [RecipeCollection] {
        guard let userID = Auth.auth().currentUser?.uid else { throw CollectionError.noUserLoggedIn }
        
        let snapshot = try await db.collection("users").document(userID).collection("collections").getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    // ✅ Neue Sammlung erstellen
    func createCollection(name: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw CollectionError.noUserLoggedIn }
        
        let collection = RecipeCollection(name: name, recipeIDs: [])
        let collectionRef = db.collection("users").document(userID).collection("collections").document()
        
        try await collectionRef.setData(from: collection)
        
        print("✅ Sammlung erstellt: \(name)")
    }
    
    // ✅ Rezept zu einer Sammlung hinzufügen
    func addRecipeToCollection(collectionID: String, recipeID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw CollectionError.noUserLoggedIn }
        
        let collectionRef = db.collection("users").document(userID).collection("collections").document(collectionID)
        
        try await collectionRef.updateData([
            "recipeIDs": FieldValue.arrayUnion([recipeID])
        ])
        print("✅ Rezept zur Sammlung hinzugefügt")
    }
    
    func removeRecipeFromCollection(collectionID: String, recipeID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { throw CollectionError.noUserLoggedIn }

        let collectionRef = db.collection("users").document(userID).collection("collections").document(collectionID)

        try await collectionRef.updateData([
            "recipeIDs": FieldValue.arrayRemove([recipeID])
        ])

        print("🔥 Rezept \(recipeID) aus Sammlung \(collectionID) entfernt")
    }
    
    enum CollectionError: LocalizedError {
        case noUserLoggedIn
        var errorDescription: String? { return "Kein Benutzer eingeloggt." }
    }
}
