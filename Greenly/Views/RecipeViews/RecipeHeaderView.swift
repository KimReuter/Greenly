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
    @Binding var showEditView: Bool
    @Binding var showAlert: Bool
    @Binding var showDeleteAlert: Bool
    
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
                                .foregroundColor(.blue)
                        }

                        // 🗑 Löschen-Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: { shareRecipe() }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                    
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
    }
    
    func shareRecipe() {
        print("📤 Rezept teilen")
    }
}
