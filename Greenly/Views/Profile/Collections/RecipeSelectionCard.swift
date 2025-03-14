//
//  RecipeSelectionCard.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import SwiftUI

struct RecipeSelectionCard: View {
    let recipe: Recipe
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RecipeCardView(recipe: recipe) // Nutzt das gleiche Design wie die Sammlung
            
             //✅ Schöner platzierte Checkbox
            Circle()
                .fill(isSelected ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: isSelected ? "checkmark" : "")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                )
                .padding(8)
                .onTapGesture {
                    onTap()
                }
        }
    }
}
