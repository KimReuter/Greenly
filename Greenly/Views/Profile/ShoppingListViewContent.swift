//
//  ShoppingListViewContent.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import SwiftUI

struct ShoppingListViewContent: View {
    @Bindable var recipeVM: RecipeViewModel
    @Binding var checkedItems: Set<String>

    var body: some View {
        if recipeVM.shoppingList.isEmpty {
            Text("🛒 Deine Einkaufsliste ist leer!")
                .foregroundColor(.gray)
                .padding()
        } else {
            List {
                ForEach(recipeVM.shoppingList, id: \.name) { ingredient in
                    HStack {
                        Button {
                            recipeVM.handleIngredientSelection(ingredient)
                        } label: {
                            Image(systemName: recipeVM.checkedItems.contains(ingredient.name) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.green)
                                .animation(.easeInOut(duration: 0.3), value: recipeVM.checkedItems)
                        }

                        VStack(alignment: .leading) {
                            Text(ingredient.name)
                                .font(.headline)
                            if let quantity = ingredient.quantity {
                                Text("\(quantity, specifier: "%.2f") benötigt")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button {
                            Task { await recipeVM.removeFromShoppingList(ingredient) }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}
