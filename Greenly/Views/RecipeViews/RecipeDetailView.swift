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
    @Bindable var collectionVM: CollectionViewModel
    
    @State private var showAlert: Bool = false
    @State private var showEditView = false
    @State private var showSaveAlert = false
    @State private var showDeleteAlert = false
    @State private var showPreparationSteps = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .bottom) {
                    
                    RecipeImageView(imageUrl: recipe.imageUrl)
                    
                    RecipeHeaderView(recipe: recipe, recipeVM: recipeVM, collectionVM: collectionVM, showEditView: $showEditView, showAlert: $showAlert, showDeleteAlert: $showDeleteAlert)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                
                // 🔥 Rezeptbeschreibung
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(recipe.description)
                            .font(.body)
                            .italic()
                            .padding(.horizontal)
                        
                        RecipeIngredientsView(recipe: recipe)
                    }
                    .padding()
                }
                
                CreateButton(label: "Jetzt zubereiten") {
                    Task {
                        await recipeVM.consumeIngredientsForRecipe(recipe)
                        showPreparationSteps.toggle()
                    }
                }
                .padding(.bottom)
                .task {
                    await recipeVM.fetchPreparationSteps(for: recipe)
                }
                .fullScreenCover(isPresented: $showPreparationSteps) {
                    if !recipeVM.preparationSteps.isEmpty {
                        StepByStepPreparationView(steps: recipeVM.preparationSteps)
                    } else {
                        Text("Keine Zubereitungsschritte vorhanden.")
                            .font(.headline)
                            .padding()
                    }
                }
            }
        }
        .background(Color("backgroundPrimary"))
        .edgesIgnoringSafeArea(.top)
        .task {
            await recipeVM.fetchIngredients(for: recipe)
            
            if let updatedRecipe = recipeVM.recipes.first(where: { $0.id == recipe.id }) {
                recipe.ingredients = updatedRecipe.ingredients
            }
        }
        .onAppear {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
        }
        .onDisappear {
            NotificationCenter.default.post(name: .showTabBar, object: nil)
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
        .presentationDetents([.medium, .large])
        .alert("✅ Gespeichert!", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Dein Rezept wurde erfolgreich gespeichert.")
        }
        .alert("Rezept löschen?", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) {}
                .foregroundStyle(.white)
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
    
}


