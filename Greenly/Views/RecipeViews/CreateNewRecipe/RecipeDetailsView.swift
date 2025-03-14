//
//  RecipeDetailsView.swift
//  Greenly
//
//  Created by Kim Reuter on 14.03.25.
//

import SwiftUI

struct RecipeDetailsView: View {
    @Binding var recipeName: String
    @Binding var recipeDescription: String
    @Binding var selectedCategories: Set<RecipeCategory>
    @State private var showCategoryPicker = false

    var body: some View {
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
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(selectedCategories: $selectedCategories)
        }
    }
}
