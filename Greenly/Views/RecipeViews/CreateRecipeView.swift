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
                
                Section(header: Text("Rezept Bild")) {
                    if let image = recipeVM.selectedImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Text("Kein Bild ausgewählt")
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker("📸 Bild auswählen", selection: $recipeVM.selectedImageItem)
                        .onChange(of: recipeVM.selectedImageItem) {
                            recipeVM.fetchImageFromStorage()
                        }
                    
                    if recipeVM.selectedImage != nil {
                        Button("🌐 Hochladen") {
                            Task {
                                do {
                                    let imageUrl = try await recipeVM.uploadImage(data: recipeVM.selectedImageData!)
                                    print("✅ Bild hochgeladen: \(imageUrl)")
                                } catch {
                                    print("❌ Fehler beim Hochladen des Bildes: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    
                    if let uploadedImageURL = recipeVM.uploadedImageURL {
                        AsyncImage(url: uploadedImageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Button("❌ Bild löschen") {
                            Task {
                                await recipeVM.deleteImage()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Rezept Details")) {
                    TextField("Name", text: $recipeName)
                    TextField("Beschreibung", text: $recipeDescription)
                }
                
                Section(header: Text("Kategorien")) {
                    Button(action: {
                        showCategoryPicker.toggle()
                    }) {
                        HStack {
                            Text(selectedCategories.isEmpty ? "Kategorie wählen" : selectedCategories.map { $0.name }.joined(separator: ", "))
                                .foregroundColor(selectedCategories.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
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
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategories: $selectedCategories)
            }
            .alert("Rezept gespeichert!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss() // 🆕 Erst nach Bestätigung schließt sich die View
                }
            } message: {
                Text("Dein Rezept wurde erfolgreich erstellt.")
            }
        }
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
                ingredients: ingredients.map { Ingredient(name: $0.name, quantity: $0.quantity) },
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
            }
            .navigationTitle("Kategorien wählen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
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

