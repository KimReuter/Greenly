//
//  RecipeGridView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import SwiftUI

struct RecipeGridView: View {
    
    @Bindable var recipeVM: RecipeViewModel
    @Bindable var collectionVM: CollectionViewModel
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(recipeVM.filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeVM: recipeVM, collectionVM: collectionVM)) {
                        RecipeCardView(recipe: recipe)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
