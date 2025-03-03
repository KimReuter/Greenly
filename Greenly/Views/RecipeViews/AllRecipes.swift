//
//  Rezepte.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import SwiftUI

struct AllRecipes: View {
    @Bindable var recipeVM: RecipeViewModel
    @State private var showCreateRecipeSheet = false
    @State private var showSearchSheet = false

    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                // 🔹 Falls Filter aktiv sind, zeigen wir sie als "Tags" an
                if !recipeVM.searchQuery.isEmpty || !recipeVM.selectedCategory.isEmpty || !recipeVM.selectedIngredient.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if !recipeVM.searchQuery.isEmpty {
                                FilterTag(text: recipeVM.searchQuery, filterType: .searchQuery, recipeVM: recipeVM)
                            }
                            if !recipeVM.selectedCategory.isEmpty {
                                ForEach(Array(recipeVM.selectedCategory), id: \.self) { category in
                                    FilterTag(text: category.name, filterType: .category, recipeVM: recipeVM)
                                }
                            }
                            if !recipeVM.selectedIngredient.isEmpty {
                                FilterTag(text: recipeVM.selectedIngredient, filterType: .ingredient, recipeVM: recipeVM)
                            }
                        }
                        .padding()
                    }
                }

                // 🔹 Alle Rezepte anzeigen (ohne direkte Sortierung)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(recipeVM.filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeVM: recipeVM)) {
                                RecipeCardView(recipe: recipe)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 80)
                .navigationTitle("Alle Rezepte")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                showSearchSheet = true
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }

                            Button {
                                showCreateRecipeSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showSearchSheet) {
                    RecipeSearchView(recipeVM: recipeVM, isPresented: $showSearchSheet)
                        .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showCreateRecipeSheet) {
                    CreateRecipeView(recipeVM: RecipeViewModel())
                        .presentationDetents([.medium, .large])
                }
            }
            .background(Color("background"))
        }
    }
}

#Preview {
    AllRecipes(recipeVM: RecipeViewModel())
}


