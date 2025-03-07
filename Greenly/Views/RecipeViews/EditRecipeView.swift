//
//  EditRecipeView.swift
//  Greenly
//
//  Created by Kim Reuter on 07.03.25.
//

import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var recipeVM: RecipeViewModel
    @State var recipe: Recipe
    @State private var newName: String
    @State private var newDescription: String
    @State private var newImageItem: PhotosPickerItem?
    @State private var newImageData: Data?
    
    init(recipe: Recipe, recipeVM: RecipeViewModel) {
        self.recipe = recipe
        self.recipeVM = recipeVM
        self._newName = State(initialValue: recipe.name)
        self._newDescription = State(initialValue: recipe.description ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Rezeptname", text: $newName)
                }

                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung", text: $newDescription)
                }

                Section(header: Text("Bild ändern")) {
                    if let newImageData, let uiImage = UIImage(data: newImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        AsyncImage(url: URL(string: recipe.imageUrl ?? "")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                    PhotosPicker("Neues Bild auswählen", selection: $newImageItem)
                        .onChange(of: newImageItem) {
                            Task {
                                newImageData = try? await newImageItem?.loadTransferable(type: Data.self)
                            }
                        }
                }
            }
            .navigationTitle("Rezept bearbeiten")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        Task {
                            var updatedRecipe = recipe
                            updatedRecipe.name = newName
                            updatedRecipe.description = newDescription

                            await recipeVM.updateRecipe(recipe, newImageData: newImageData)
                            dismiss() // 🔥 Nach dem Speichern schließen
                        }
                    }
                }
            }
        }
    }
}
