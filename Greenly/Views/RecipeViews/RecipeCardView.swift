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
                if let imageUrl = recipe.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .cornerRadius(8)
                                .clipped()
                        case .failure:
                            Color.gray.opacity(0.3)
                                .overlay {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.gray)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Falls kein Bild vorhanden ist, zeige Platzhalter
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
            .frame(height: 100) // Höhe für das Bild
            
            // 🔹 Rezeptname (mehrzeilig)
            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .foregroundStyle(Color("buttonPrimary"))
            
            // 🔹 Kategorie als kleiner Chip (optional)
            if !recipe.category.isEmpty {
                HStack {
                    ForEach(recipe.category, id: \.self) { cat in
                        Text(cat.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(.blue).opacity(0.1))
                            .foregroundStyle(Color("buttonPrimary"))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .frame(width: 160, height: 200)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
    }
}
