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
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        let filteredRecipes = recipeVM.filteredRecipes.filter { $0.category.contains(category) }
                        if !filteredRecipes.isEmpty {
                            CategorySection(category: category, recipes: filteredRecipes, recipeVM: recipeVM)
                        }
                    }
                }
            }
            .padding(.bottom, 80)
            .navigationTitle("Alle Rezepte")
            .globalBackground()
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
            }
            .sheet(isPresented: $showCreateRecipeSheet) {
                CreateRecipeView()
            }
        }
    }
}

#Preview {
    AllRecipes(recipeVM: RecipeViewModel())
}
