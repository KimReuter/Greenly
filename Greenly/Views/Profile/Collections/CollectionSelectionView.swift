//
//  CollectionSelectionView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import SwiftUI

struct CollectionSelectionView: View {
    let recipe: Recipe
    @Bindable var collectionVM: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCollectionIDs: Set<String> = []
    @Binding var showSuccessAlert: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(collectionVM.collections) { collection in
                        HStack {
                            Text(collection.name)
                            Spacer()
                            if selectedCollectionIDs.contains(collection.id ?? "") {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(for: collection)
                        }
                    }
                }
            }
            .navigationTitle("Sammlung auswählen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hinzufügen") {
                        Task {
                            await addRecipeToSelectedCollections()
                            dismiss()
                        }
                    }
                    .disabled(selectedCollectionIDs.isEmpty)
                }
            }
        }
        .task {
            await collectionVM.fetchCollections()
        }
    }
    
    private func toggleSelection(for collection: RecipeCollection) {
        if let id = collection.id {
            if selectedCollectionIDs.contains(id) {
                selectedCollectionIDs.remove(id)
            } else {
                selectedCollectionIDs.insert(id)
            }
        }
    }
    
    private func addRecipeToSelectedCollections() async {
        for collectionID in selectedCollectionIDs {
            await collectionVM.addRecipesToCollection(collectionID: collectionID, recipeIDs: [recipe.id ?? ""])
        }
        showSuccessAlert = true
    }
}
