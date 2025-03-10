//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 24.02.25.
//

//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 24.02.25.
//

import SwiftUI

struct RecipeDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var recipe: Recipe
    @Bindable var recipeVM: RecipeViewModel
    @State private var showAlert: Bool = false
    @State private var showEditView = false
    @State private var showSaveAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                
                RecipeImageView(imageUrl: recipe.imageUrl)
                
                RecipeHeaderView(recipe: recipe, recipeVM: recipeVM, showEditView: $showEditView, showAlert: $showAlert, showDeleteAlert: $showDeleteAlert)
            }
            .frame(height: UIScreen.main.bounds.height * 0.5)
            
            // 🔥 Rezeptbeschreibung
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.description ?? "")
                        .font(.body)
                        .italic()
                        .padding(.horizontal)
                    
                    Text("🛒 Zutaten")
                        .font(.headline)
                        .padding(.top)
                    
                    if (recipe.ingredients ?? []).isEmpty {
                        Text("Keine Zutaten vorhanden")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recipe.ingredients ?? [], id: \.id) { ingredient in
                            HStack {
                                Text("• \(ingredient.name)")
                                    .font(.body)
                                if let quantity = ingredient.quantity {
                                    Text("(\(quantity, specifier: "%.2f"))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            CreateButton(label: "Jetzt zubereiten") {
                Task {
                    await recipeVM.consumeIngredientsForRecipe(recipe)
                }
            }
            .padding(.bottom)
        }
        .background(Color("background"))
        .edgesIgnoringSafeArea(.top)
        .task {
            await recipeVM.fetchIngredients(for: recipe)
            
            if let updatedRecipe = recipeVM.recipes.first(where: { $0.id == recipe.id }) {
                recipe.ingredients = updatedRecipe.ingredients
            }
        }
        .alert("Hinzugefügt!", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Die Zutaten wurden zur Einkaufsliste hinzugefügt.")
        }
        .sheet(isPresented: $showEditView, onDismiss: {
            if let updatedRecipe = recipeVM.recipes.first(where: { $0.id == recipe.id }) {
                recipe = updatedRecipe
                showSaveAlert = true // ✅ Alert anzeigen
            }
        }) {
            EditRecipeView(recipe: recipe, recipeVM: recipeVM)
        }
        .alert("✅ Gespeichert!", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Dein Rezept wurde erfolgreich gespeichert.")
        }
        .alert("Rezept löschen?", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                Task {
                    await recipeVM.deleteRecipe(recipe)
                    dismiss() // 🔄 Detail-Ansicht schließen
                }
            }
        } message: {
            Text("Möchtest du dieses Rezept wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }

    
    // Funktionen
    
    
    func prepareRecipe() {
        print("🍽 Rezept starten")
    }
}


