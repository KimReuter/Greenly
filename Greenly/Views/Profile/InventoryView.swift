//
//  InventoryView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct InventoryView: View {
    @State private var inventoryItems: [String] = ["Natron", "Sheabutter", "Apfelessig"]
    @State private var newItem: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Zutat hinzufügen...", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                }
                .padding()

                List {
                    ForEach(inventoryItems, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            Button(action: {
                                removeItem(item)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("📦 Vorrat")
        }
    }

    private func addItem() {
        guard !newItem.isEmpty else { return }
        inventoryItems.append(newItem)
        newItem = ""
    }

    private func removeItem(_ item: String) {
        inventoryItems.removeAll { $0 == item }
    }
}

#Preview {
    InventoryView()
}
