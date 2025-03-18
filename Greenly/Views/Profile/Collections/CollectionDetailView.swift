//
//  CollectionDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

//
//  CollectionDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import SwiftUI

struct CollectionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var collection: RecipeCollection
    
    @Bindable var collectionVM: CollectionViewModel
    @Bindable var recipeVM: RecipeViewModel
    
    @State var showAddRecipesSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if collection.recipeIDs.isEmpty {
                    EmptyCollectionView(showAddRecipesSheet: $showAddRecipesSheet)
                } else {
                    CollectionRecipeGridView(collection: collection, collectionVM: collectionVM, recipeVM: recipeVM)
                }
            }
            
            .background(Color("background"))
            .navigationTitle(collection.name)
            .onAppear {
                Task {
                    await collectionVM.fetchRecipesForCollection(collection: collection)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddRecipesSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddRecipesSheet) {
            AddRecipesToCollectionView(collection: collection, collectionVM: collectionVM, recipeVM: recipeVM)
        }
    }
}
