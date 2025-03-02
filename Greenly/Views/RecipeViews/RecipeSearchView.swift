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
                
                Section(header: Text("Kategorien wählen")) {
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        Toggle(isOn: Binding(
                            get: { recipeVM.selectedCategory.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    recipeVM.selectedCategory.insert(category) // ✅ Korrekt für Set
                                } else {
                                    recipeVM.selectedCategory.remove(category) // ✅ Entfernen aus Set
                                }
                            }
                        )) {
                            Text(category.name)
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
