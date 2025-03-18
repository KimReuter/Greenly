//
//  IngredientListView.swift
//  Greenly
//
//  Created by Kim Reuter on 14.03.25.
//

import SwiftUI

struct IngredientListView: View {
    @Binding var ingredients: [IngredientInput]

    var body: some View {
        Section(header: Text("Zutaten")) {
            ForEach($ingredients) { $ingredient in
                IngredientInputRow(ingredient: $ingredient) {
                    ingredients.removeAll { $0.id == ingredient.id }
                }
            }

            Button(action: {
                ingredients.append(IngredientInput(name: "", quantity: 0, unit: .gram))
            }) {
                Label("Zutat hinzufügen", systemImage: "plus")
                    .foregroundStyle(.white)
            }
        }
    }
}
