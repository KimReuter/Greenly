//
//  AddRecipesToCollection.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import SwiftUI

struct AddRecipesToCollectionView: View {
    @Environment(\.dismiss) var dismiss
    @State var collection: RecipeCollection
    @Bindable var collectionVM: CollectionViewModel
    @Bindable var recipeVM: RecipeViewModel
    @State private var selectedRecipeIDs: Set<String> = []
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if recipeVM.recipes.isEmpty {
                    Text("⚠️ Keine Rezepte verfügbar")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(recipeVM.recipes) { recipe in
                                RecipeSelectionCard(recipe: recipe, isSelected: selectedRecipeIDs.contains(recipe.id ?? "")) {
                                    toggleSelection(for: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .alert("Rezept hinzugefügt!", isPresented: $showAlert) {
                Button("OK") {
                    dismiss() // 🆕 Erst nach Bestätigung schließt sich die View
                }
            } message: {
                Text("Dein Rezept wurde erfolgreich hinzugefügt.")
            }
            .background(Color("background"))
            .navigationTitle("Rezepte auswählen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hinzufügen") {
                        Task {
                            await collectionVM.addRecipesToCollection(collectionID: collection.id ?? "", recipeIDs: Array(selectedRecipeIDs))
                            showAlert = true
                        }
                    }
                    .disabled(selectedRecipeIDs.isEmpty) // Button nur aktivieren, wenn etwas ausgewählt wurde
                }
            }
        }
        .task {
            await recipeVM.fetchRecipes()
        }
    }

    private func toggleSelection(for recipe: Recipe) {
        if let id = recipe.id {
            if selectedRecipeIDs.contains(id) {
                selectedRecipeIDs.remove(id)
            } else {
                selectedRecipeIDs.insert(id)
            }
        }
    }
}
