//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            
        }
    }
}

#Preview {
    RecipeDetailView(recipe: Recipe(id: UUID(), name: "Orangen - Peeling", description: "Ein herrlich erfrischendes Peeling für Lippen & Körper", category: .bodyCare, author: "Admin", ingredients: [Ingredient(id: UUID(), name: "Zucker", quantity: 100, unit: .gram, category: .different), Ingredient(id: UUID(), name: "Ätherisches Orangenöl", quantity: 10, unit: .drop, category: .essentialOil)], preparationTime: 10, difficulty: .easy, preparationSteps: [.prepareWorkstation, .addActives,.addEssentialOils, .blendLiquids, .checkConsistency,.labelAndStore], pictureURL: "", tags: ["winter", "citrus", "fresh"]))
}
