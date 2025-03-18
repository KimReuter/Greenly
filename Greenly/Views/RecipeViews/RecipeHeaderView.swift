//
//  RecipeHeaderView.swift
//  Greenly
//
//  Created by Kim Reuter on 07.03.25.
//

import SwiftUI

struct RecipeHeaderView: View {
    
    let recipe: Recipe
    
    @Bindable var recipeVM: RecipeViewModel
    @Bindable var collectionVM: CollectionViewModel
    
    @Binding var showEditView: Bool
    @Binding var showAlert: Bool
    @Binding var showDeleteAlert: Bool
    
    @State private var showCollectionSelection = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Text(recipe.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 15) {
                    
                    // ✏️ Bearbeiten-Button, nur wenn User der Ersteller ist
                    if let currentUserID = recipeVM.currentUserID, recipe.authorID == currentUserID {
                        Button(action: {
                            showEditView = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundStyle(.white)
                        }
                        
                        // 🗑 Löschen-Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // ➕ Button zum Hinzufügen zu einer Sammlung
                    Button {
                        showCollectionSelection = true
                    } label: {
                        Image(systemName: "text.badge.plus")
                            .foregroundColor(.white)
                    }
                    
                    // 🛒 Einkaufsliste
                    Button {
                        Task {
                            await recipeVM.checkAndUpdateShoppingList(for: recipe)
                            showAlert = true
                        }
                    } label: {
                        Image(systemName: "cart.badge.plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.4))
        }
        .sheet(isPresented: $showCollectionSelection) {
            CollectionSelectionView(recipe: recipe, collectionVM: collectionVM, showSuccessAlert: $showSuccessAlert)
        }
        .presentationDetents([.medium, .large])
        .alert("✅ Rezept hinzugefügt!", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Das Rezept wurde erfolgreich zur Sammlung hinzugefügt.")
                }
    }
    
}
