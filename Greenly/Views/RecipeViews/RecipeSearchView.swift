//
//  RecipeSearchView.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

import SwiftUI

struct RecipeSearchView: View {
    @Bindable var recipeVM: RecipeViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nach Name oder Beschreibung suchen")) {
                    TextField("Suchtext eingeben...", text: $recipeVM.searchQuery)
                }
                
                Section(header: Text("Kategorie wählen")) {
                    Picker("Kategorie", selection: $recipeVM.selectedCategory) {
                        Text("Alle Kategorien").tag(nil as RecipeCategory?)
                        ForEach(RecipeCategory.allCases, id: \.self) { category in
                            Text(category.name).tag(category as RecipeCategory?)
                        }
                    }
                }
                
                Section(header: Text("Nach einer Zutat filtern")) {
                    TextField("Zutat eingeben...", text: $recipeVM.selectedIngredient)
                }
            }
            .navigationTitle("Rezept-Suche")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Suchen") {
                        Task {
                            await recipeVM.applyFilters() // 🔥 Fix: Suche wird angewendet
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunde warten, damit UI sich aktualisiert
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
