//
//  CollectionsView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct CollectionsView: View {
    
    @Bindable var collectionVM: CollectionViewModel
    @Bindable var recipeVM: RecipeViewModel
    
    @State private var showCreateCollection = false
    @State private var newCollectionName = ""

    var body: some View {
        NavigationStack {
            VStack {
                if collectionVM.collections.isEmpty {
                    Text("📂 Du hast noch keine Sammlungen erstellt.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(collectionVM.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection, collectionVM: collectionVM, recipeVM: recipeVM)) {
                                Text(collection.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meine Sammlungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateCollection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateCollection) {
                VStack {
                    Text("Neue Sammlung erstellen")
                        .font(.headline)
                    TextField("Name der Sammlung", text: $newCollectionName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button("Erstellen") {
                        Task {
                            await collectionVM.createCollection(name: newCollectionName)
                            showCreateCollection = false
                            newCollectionName = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .task {
                await collectionVM.fetchCollections()
            }
        }
    }
}
