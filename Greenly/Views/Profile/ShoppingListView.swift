//
//  ShoppingListView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct ShoppingListView: View {
    @State private var shoppingItems: [String] = ["Heilerde", "Kokosöl", "Zitronensäure"]
    @State private var newItem: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Neues Produkt...", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
                .padding()

                List {
                    ForEach(shoppingItems, id: \.self) { item in
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
            .navigationTitle("🛒 Einkaufsliste")
        }
    }

    private func addItem() {
        guard !newItem.isEmpty else { return }
        shoppingItems.append(newItem)
        newItem = ""
    }

    private func removeItem(_ item: String) {
        shoppingItems.removeAll { $0 == item }
    }
}
#Preview {
    ShoppingListView()
}
