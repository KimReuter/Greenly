//
//  Rezepte.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import SwiftUI

struct AllRecipes: View {
    
    @Bindable var recipeVM: RecipeViewModel
    @Bindable var collectionVM: CollectionViewModel
    
    @State private var showCreateRecipeSheet = false
    @State private var showSearchSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                // 🔹 Falls Filter aktiv sind, zeigen wir sie als "Tags" an
                if !recipeVM.searchQuery.isEmpty || !recipeVM.selectedCategory.isEmpty || !recipeVM.selectedIngredient.isEmpty {
                    FilterTagsView(recipeVM: recipeVM)
                }

                // 🔹 Alle Rezepte anzeigen (ohne direkte Sortierung)
                RecipeGridView(recipeVM: recipeVM, collectionVM: collectionVM)
                .padding(.bottom, 80)
                .navigationTitle("Alle Rezepte")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                showSearchSheet = true
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Color("textPrimary"))
                            }

                            Button {
                                showCreateRecipeSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color("textPrimary"))

                            }
                        }
                    }
                }
                .sheet(isPresented: $showSearchSheet) {
                    RecipeSearchView(recipeVM: recipeVM, isPresented: $showSearchSheet)
                        .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showCreateRecipeSheet) {
                    CreateRecipeView(recipeVM: RecipeViewModel(imageRepository: ImgurImageRepository(clientID: "6261d10abfac0c8")))
                        .presentationDetents([.medium, .large])
                }
            }
            .background(Color("backgroundPrimary"))
            .onAppear {
                Task {
                    do {
                        try await recipeVM.fetchRecipes() // 🔥 Diese Funktion gibt `Void` zurück, daher kein `let testRecipes = ...`
                        print("📥 Test: \(recipeVM.recipes.count) Rezepte aus Firestore geladen") // Nutze direkt `recipeVM.recipes`
                    } catch {
                        print("❌ Fehler beim Testladen der Rezepte: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


