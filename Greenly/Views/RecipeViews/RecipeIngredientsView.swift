//
//  RecipeIngredientsView.swift
//  Greenly
//
//  Created by Kim Reuter on 14.03.25.
//

import SwiftUI

struct RecipeIngredientsView: View {
    var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text("🛒 Zutaten")
                .font(.headline)
                .padding(.top)

            if (recipe.ingredients ?? []).isEmpty {
                Text("Keine Zutaten vorhanden")
                    .foregroundColor(.gray)
            } else {
                ForEach(recipe.ingredients ?? [], id: \.id) { ingredient in
                    HStack {
                        Text("• \(ingredient.name)")
                            .font(.body)
                        if let quantity = ingredient.quantity {
                            Text("(\(quantity, specifier: "%.2f"))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Text(ingredient.unit?.name ?? "Gramm")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
