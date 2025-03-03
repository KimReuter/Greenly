//
//  FilterTag.swift
//  Greenly
//
//  Created by Kim Reuter on 01.03.25.
//

import SwiftUI

struct FilterTag: View {
    var text: String
    var filterType: FilterType
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        HStack {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(20)
            
            Button(action: {
                Task {
                    await recipeVM.clearFilter(recipeVM.currentFilter!)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(5)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

#Preview {
    FilterTag(text: "", filterType: .category, recipeVM: RecipeViewModel())
}
