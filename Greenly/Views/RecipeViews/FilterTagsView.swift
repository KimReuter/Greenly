//
//  FilterTagsView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import SwiftUI

struct FilterTagsView: View {
    @Bindable var recipeVM: RecipeViewModel

    var body: some View {
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
}
