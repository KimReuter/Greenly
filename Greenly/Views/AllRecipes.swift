//
//  Rezepte.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import SwiftUI

struct AllRecipes: View {
    
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                List(recipeVM.recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        HStack {
                            Text(recipe.name)
                                .font(.headline)
                            Spacer()
                            Text(recipe.category)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Alle Rezepte")
        .task {
            await recipeVM.fetchRecipes()
        }
    }
}

#Preview {
    AllRecipes(recipeVM: RecipeViewModel())
}
