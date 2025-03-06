//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 24.02.25.
//

//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 24.02.25.
//

import SwiftUI

import SwiftUI

struct RecipeDetailView: View {
    
    @State var recipe: Recipe
    @Bindable var recipeVM: RecipeViewModel
    @State private var showAlert: Bool = false
    @State private var imageOpacity: Double = 1  // Für den Fade-Effekt
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                // 🔥 Bild direkt laden, ohne GeometryReader!
                if let imageUrl = recipe.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: UIScreen.main.bounds.height * 0.5)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                                .clipped()
                                .opacity(imageOpacity)
                        case .failure:
                            Color.gray.opacity(0.3)
                                .frame(height: UIScreen.main.bounds.height * 0.5)
                                .overlay {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                }

                // 🔥 Rezeptname + Buttons über Bild
                VStack {
                    HStack {
                        Text(recipe.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: { shareRecipe() }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                            }
                        
                            Button {
                                Task {
                                    await recipeVM.checkAndUpdateShoppingList(for: recipe)
                                    showAlert = true
                                }
                            } label: {
                                Image(systemName: "cart.badge.plus")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.5) // Bild ist 50% der Screenhöhe
            
            // 🔥 Rezeptbeschreibung
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.description ?? "")
                        .font(.body)
                        .italic()
                        .padding(.horizontal)
                    
                    Text("🛒 Zutaten")
                        .font(.headline)
                        .padding(.top)
                    
                    if (recipe.ingredients ?? []).isEmpty {
                        Text("Keine Zutaten vorhanden")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recipe.ingredients ?? [], id: \.id) { ingredient in
                            HStack {
                                Text("• \(ingredient.name)")
                                    .font(.body)
                                if let quantity = ingredient.quantity {
                                    Text("(\(quantity, specifier: "%.2f"))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .toolbar(.hidden, for: .tabBar)
            
            CreateButton(label: "Jetzt zubereiten") {
                Task {
                    await recipeVM.consumeIngredientsForRecipe(recipe)
                }
            }
            .padding(.bottom)
        }
        .toolbar(.hidden, for: .tabBar)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.top)
        .task {
            await recipeVM.fetchIngredients(for: recipe)

            if let updatedRecipe = recipeVM.recipes.first(where: { $0.id == recipe.id }) {
                recipe.ingredients = updatedRecipe.ingredients
            }
        }
        .alert("Hinzugefügt!", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Die Zutaten wurden zur Einkaufsliste hinzugefügt.")
        }
    }
    
    // Funktionen
    func shareRecipe() {
        print("📤 Rezept teilen")
    }
    
    func prepareRecipe() {
        print("🍽 Rezept starten")
    }
}


