//
//  CreateRecipeView.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

//
//  CreateRecipeView.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

import SwiftUI

struct CreateRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var recipeVM: RecipeViewModel // 🔥 ViewModel als StateObject
    @State private var recipeName = ""
    @State private var recipeDescription = ""
    @State private var selectedCategories: Set<RecipeCategory> = []
    @State private var ingredients: [IngredientInput] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rezept Details")) {
                    TextField("Name", text: $recipeName)
                    TextField("Beschreibung", text: $recipeDescription)
                }

                Section(header: Text("Kategorie")) {
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        MultipleSelectionRow(title: category.name, isSelected: selectedCategories.contains(category)) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }

                Section(header: Text("Zutaten")) {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            TextField("Zutat", text: $ingredient.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Menge", value: $ingredient.quantity, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .frame(width: 80)

                            Button(action: {
                                ingredients.removeAll { $0.id == ingredient.id }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        ingredients.append(IngredientInput(name: "", quantity: 0))
                    }) {
                        Label("Zutat hinzufügen", systemImage: "plus")
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Rezept erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        Task {
                            await saveRecipe()
                        }
                    }
                }
            }
        }
    }

    func saveRecipe() async {
        let newRecipe = Recipe(
            name: recipeName,
            description: recipeDescription,
            category: Array(selectedCategories),
            ingredients: ingredients.map { Ingredient(name: $0.name, quantity: $0.quantity) }
        )

        do {
            try await recipeVM.createRecipe(newRecipe) // 🔥 Aufruf über ViewModel
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// 🆕 Hilfsstruktur für Eingabe
struct IngredientInput: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Double
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    CreateRecipeView(recipeVM: RecipeViewModel())
}
