//
//  RecipeCardView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//
import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 🔹 Bild oben (oder Platzhalter)
            ZStack {
                if let imageName = recipe.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Platzhalter
                    Color.gray.opacity(0.3)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray)
                        }
                }
            }
            .frame(height: 100)       // Höhe für das Bild
            .cornerRadius(8)
            .clipped()
            
            // 🔹 Rezeptname (mehrzeilig)
            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)              // max. 2 Zeilen
                .minimumScaleFactor(0.8)   // verkleinert Schrift bei langem Text
            
            // 🔹 Kategorie als kleiner Chip (optional)
            if !recipe.category.isEmpty {
                HStack {
                    ForEach(recipe.category, id: \.self) { cat in
                        Text(cat.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .frame(width: 160, height: 200) // Einheitliche Kartengröße
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
    }
}

#Preview {
    RecipeCardView(recipe: Recipe(name: "Test Rezept", description: "Lecker und nachhaltig", category: [.bodyCare]))
}
