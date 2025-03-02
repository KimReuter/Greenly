//
//  CollectionsView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct CollectionsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hier kommen deine Rezept-Sammlungen! 📂")
                    .font(.title2)
                    .padding()
                Spacer()
            }
            .navigationTitle("Meine Sammlungen")
        }
    }
}

#Preview {
    CollectionsView()
}
