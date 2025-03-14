//
//  ProfileView.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @State private var showCollectionSheet = false
    @State private var showInventorySheet = false
    @State private var showShoppingListSheet = false
    
    @Bindable var authVM: AuthenticationViewModel
    @Bindable var recipeVM: RecipeViewModel
    @Bindable var userVM: UserViewModel
    @Bindable var collectionVM: CollectionViewModel

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 🔹 Begrüßung & Profilbild
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hallo, Kim! 👋")
                                .font(.title)
                                .bold()
                            Text("Hier siehst du deine persönlichen Inhalte.")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                        ProfilePictureView(userVM: userVM)
                    }
                    .padding(.horizontal)

                    // 🔹 Schnellzugriff auf Sammlungen, Vorrat, Einkaufsliste
                    VStack(spacing: 16) {
                        ProfileButton(icon: "bookmark.fill", title: "Meine Sammlungen", action: {
                            showCollectionSheet.toggle()
                        })
                        
                        ProfileButton(icon: "cart.fill", title: "Einkaufszettel", action: {
                            showShoppingListSheet.toggle()
                        })
                        
                        ProfileButton(icon: "shippingbox.fill", title: "Vorrat", action: {
                            showInventorySheet.toggle()
                        })
                    }
                    .padding(.horizontal)

                    // 🔹 Gamification & Statistiken
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dein Fortschritt 📊")
                            .font(.headline)
                        
                        HStack {
                            ProgressCard(title: "Rezepte ausprobiert", value: "12")
                            ProgressCard(title: "Sammlungen erstellt", value: "3")
                            ProgressCard(title: "Zutaten im Vorrat", value: "24")
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.top)
            }
            .background(Color("background"))
            .navigationTitle("👤 Persönlich")
        }
        .sheet(isPresented: $showCollectionSheet) {
            CollectionsView(collectionVM: collectionVM, recipeVM: recipeVM)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showShoppingListSheet) {
            ShoppingListView(recipeVM: recipeVM)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showInventorySheet) {
            InventoryView(recipeVM: recipeVM)
                .presentationDetents([.medium, .large])
        }
    }
}

