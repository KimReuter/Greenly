//
//  InventoryView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//


import SwiftUI

struct InventoryView: View {
    
    @Bindable var recipeVM: RecipeViewModel
    
    @State private var newItem = ""
    @State private var quantity: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                AddIngredientView(recipeVM: recipeVM)

                // 🔥 Anzeige des Inventars
                if recipeVM.inventory.isEmpty {
                    Text("📦 Dein Vorrat ist leer!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(recipeVM.inventory, id: \.name) { ingredient in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ingredient.name)
                                        .font(.headline)
                                    if let quantity = ingredient.quantity {
                                        Text("\(quantity, specifier: "%.2f") verfügbar")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    Task {
                                        await recipeVM.removeFromInventory(ingredient.name)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("📦 Vorrat")
        }
        .task {
            await recipeVM.fetchInventory()
        }
    }
}

