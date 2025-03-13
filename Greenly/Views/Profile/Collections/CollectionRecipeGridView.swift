//
//  RecipeGridView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import SwiftUI

struct CollectionRecipeGridView: View {
    let collection: RecipeCollection
    @Bindable var collectionVM: CollectionViewModel
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(collectionVM.collectionRecipes[collection.id ?? "", default: []], id: \.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeVM: recipeVM, collectionVM: collectionVM)) {
                        RecipeCardView(recipe: recipe)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await collectionVM.removeRecipeFromCollection(collectionID: collection.id ?? "", recipeID: recipe.id ?? "")
                            }
                        } label: {
                            Label("Aus der Sammlung entfernen", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}
