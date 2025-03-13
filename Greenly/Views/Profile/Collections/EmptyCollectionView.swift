//
//  EmptyCollectionView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import SwiftUI

struct EmptyCollectionView: View {
    @Binding var showAddRecipesSheet: Bool
    
    var body: some View {
        VStack {
            Text("📂 Diese Sammlung ist leer")
                .font(.title2)
                .padding()
            
            Text("Füge Rezepte hinzu, um diese Sammlung zu füllen.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            Button(action: {
                showAddRecipesSheet = true
            }) {
                Label("Rezepte hinzufügen", systemImage: "plus.circle.fill")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
