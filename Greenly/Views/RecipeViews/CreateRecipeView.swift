//
//  CreateRecipeView.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

import SwiftUI

struct CreateRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recipeName = ""
    @State private var recipeDescription = ""
    @State private var selectedCategories: Set<RecipeCategory> = []
    @State private var ingredientsText = ""
    @State private var errorMessage: String?
    
    // Direkter Zugriff auf den RecipeManager
    let recipeManager = RecipeManager()
    
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
                    TextEditor(text: $ingredientsText)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                        .padding(.vertical, 4)
                    Text("Geben Sie Zutaten ein, getrennt durch Kommas")
                        .font(.caption)
                        .foregroundColor(.gray)
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
        // Zutaten aus dem eingegebenen Text verarbeiten (Trennung an Kommas)
        let ingredientsArray = ingredientsText
            .split(separator: ",")
            .map { Ingredient(name: String($0).trimmingCharacters(in: .whitespaces)) }
        
        let newRecipe = Recipe(
            name: recipeName,
            description: recipeDescription,
            category: Array(selectedCategories),
            ingredients: ingredientsArray
        )
        
        do {
            try await recipeManager.createRecipe(newRecipe)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
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
    CreateRecipeView()
}
