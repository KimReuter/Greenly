//
//  FavoriteRecipes.swift
//  Greenly
//
//  Created by Kim Reuter on 21.02.25.
//

import SwiftUI

struct FavoriteRecipes: View {
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if recipeVM.favoriteRecipes.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                        Text("No Favorites yet!")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(recipeVM.favoriteRecipes) { recipe in
                            VStack(alignment: .leading) {
                                Text(recipe.name)
                                    .font(.headline)
                                Text(recipe.category.map { $0.name }.joined(separator: ", ")) .font(.subheadline)
                                    .foregroundStyle(Color("secondary"))
                            }
                            .listRowSeparator(.hidden)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        await recipeVM.toggleFavorite(recipe: recipe)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                            Spacer()
                        }
                    }
                    .listRowSpacing(0)
                    .scrollContentBackground(.hidden)
                }
            }
            .globalBackground()
            .navigationTitle("Lieblingsrezepte")
            
        }
    }
}

#Preview {
    FavoriteRecipes(recipeVM: RecipeViewModel())
}
