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
    @State private var showDeleteAlert = false
    @State private var collectionToDelete: String?
    
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
                            .swipeActions {
                                Button(role: .destructive) {
                                    collectionToDelete = collection.id // 🆕 Speichert die Sammlung zum Löschen
                                    showDeleteAlert = true // 🆕 Zeigt den Alert
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .background(Color("backgroundPrimary"))
            .navigationTitle("Meine Sammlungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateCollection = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
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
                    Button {
                        Task {
                            await collectionVM.createCollection(name: newCollectionName)
                            showCreateCollection = false
                            newCollectionName = ""
                        }
                    } label: {
                        Text("Erstellen")
                            .foregroundStyle(Color("buttonPrimary"))
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .presentationDetents([.medium, .large])
            .task {
                await collectionVM.fetchCollections()
            }
            .alert("Sammlung löschen?", isPresented: $showDeleteAlert) {
                            Button("Abbrechen", role: .cancel) { }
                            Button("Löschen", role: .destructive) {
                                Task {
                                    if let collectionID = collectionToDelete {
                                        await collectionVM.deleteCollection(collectionID: collectionID)
                                        collectionToDelete = nil // Reset nach dem Löschen
                                    }
                                }
                            }
                        } message: {
                            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
                        }
        }
        
    }
}
