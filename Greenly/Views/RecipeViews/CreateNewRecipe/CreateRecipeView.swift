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
    @State private var preparationSteps: [PreparationStepType] = []
    @State private var errorMessage: String?
    @State private var showCategoryPicker = false
    @State private var showStepPicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                ImageSelectionView(recipeVM: recipeVM)
                
                RecipeDetailsView(recipeName: $recipeName, recipeDescription: $recipeDescription, selectedCategories: $selectedCategories)
                
                IngredientListView(ingredients: $ingredients)
                
                Section(header: Text("Zubereitungsschritte")) {
                    if preparationSteps.isEmpty {
                        Text("Noch keine Schritte hinzugefügt.")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(preparationSteps.indices, id: \.self) { index in
                                HStack {
                                    Text("\(index + 1).")
                                        .bold()
                                    Text(preparationSteps[index].name)
                                }
                            }
                            .onDelete { indexSet in
                                preparationSteps.remove(atOffsets: indexSet)
                            }
                            .onMove { from, to in
                                preparationSteps.move(fromOffsets: from, toOffset: to)
                            }
                        }
                    }

                    HStack {
                        Button(action: {
                            showStepPicker = true // 🆕 Hier wird das Sheet geöffnet
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.white)
                                Text("Schritt hinzufügen")
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        EditButton()
                            .foregroundStyle(.white)
                    }
                }
                
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
            .sheet(isPresented: $showStepPicker) {
                PreparationStepPickerView(selectedSteps: $preparationSteps)
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
                authorID: recipeVM.currentUserID ?? "unkwnown",
                preparationSteps: preparationSteps
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
                    MultipleSelectionRow(title: category.name, isSelected: selectedCategories.contains(category), color: .white) {
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
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(color) // 🔥 Hier wird die Schriftfarbe gesetzt
                
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

