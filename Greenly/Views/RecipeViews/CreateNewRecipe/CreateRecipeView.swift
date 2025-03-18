//
//  CreateRecipeView.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var recipeVM: RecipeViewModel
    @State private var recipeName = ""
    @State private var recipeDescription = ""
    @State private var selectedCategories: Set<RecipeCategory> = []
    @State private var ingredients: [IngredientInput] = []
    @State private var errorMessage: String?
    @State private var showCategoryPicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                ImageSelectionView(recipeVM: recipeVM)
                
                RecipeDetailsView(recipeName: $recipeName, recipeDescription: $recipeDescription, selectedCategories: $selectedCategories)
                
                IngredientListView(ingredients: $ingredients)
                
                if let errorMessage = errorMessage {
                                    Section {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                    }
                                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("backgroundPrimary"))
            .navigationTitle("Rezept erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Abbrechen")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await saveRecipe()
                        }
                    } label: {
                        Text("Speichern")
                        .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategories: $selectedCategories)
            }
            .alert("Rezept gespeichert!", isPresented: $showSuccessAlert) {
                Button {
                    dismiss() // 🆕 Erst nach Bestätigung schließt sich die View
                } label: {
                    Text("OK")
                        .foregroundStyle(.white)
                }
            } message: {
                Text("Dein Rezept wurde erfolgreich erstellt.")
            }
        }
        .background(Color("backgroundPrimary"))
    }
    
    func saveRecipe() async {
        do {
            print("🚀 Starte Upload-Prozess...")

            var imageUrl: String? = nil
            
            // Falls ein neues Bild existiert, lade es hoch
            if let imageData = recipeVM.selectedImageData {
                imageUrl = try await recipeVM.uploadImage(data: imageData)
                print("✅ Bild hochgeladen: \(imageUrl ?? "Keine URL")")
            }

            // Erstelle das Rezept-Objekt
            let newRecipe = Recipe(
                name: recipeName,
                description: recipeDescription,
                category: Array(selectedCategories),
                ingredients: ingredients.map { Ingredient(name: $0.name, quantity: $0.quantity, unit: $0.unit) },
                imageUrl: imageUrl,
                authorID: recipeVM.currentUserID ?? "unkwnown"
            )

            // Speichere das Rezept in Firestore
            try await recipeVM.createRecipe(newRecipe)
            print("✅ Rezept erfolgreich gespeichert mit Bild-URL: \(newRecipe.imageUrl ?? "Keine URL")")

            showSuccessAlert = true
        } catch {
            errorMessage = "❌ Fehler beim Speichern: \(error.localizedDescription)"
            print(errorMessage!)
        }
    }
}

// 🆕 Kategorie-Picker als eigenes Sheet
struct CategoryPickerView: View {
    @Binding var selectedCategories: Set<RecipeCategory>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    MultipleSelectionRow(title: category.name, isSelected: selectedCategories.contains(category)) {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }
                }
                .foregroundStyle(.white)
            }
            .navigationTitle("Kategorien wählen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Fertig")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

// 🆕 Hilfsstruktur für Eingabe
struct IngredientInput: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: MeasurementUnit
}

// 🆕 Hilfsstruktur für Mehrfachauswahl
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

