//
//  RecipeDetailView.swift
//  Greenly
//
//  Created by Kim Reuter on 24.02.25.
//

import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    @Bindable var recipeVM: RecipeViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                GeometryReader { geometry in
                    Image("")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                        .clipped()
                }
                .frame(height: 300)
                
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
                        
                            Button(action: {
                                Task {
                                    await recipeVM.checkAndUpdateShoppingList(for: recipe)
                                }
                            }) {
                                Label("Zum Warenkorb", systemImage: "cart.badge.plus")
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                }
            }
            
            HStack {
                Button(action: { selectedTab = 0 }) {
                    Text("Zutaten")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 0 ? Color.white : Color.clear)
                        .cornerRadius(8)
                }
                .foregroundColor(.black)
                
                Divider()
                
                Button(action: { selectedTab = 1 }) {
                    Text("Wirkstoffe")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 1 ? Color.white : Color.clear)
                        .cornerRadius(8)
                }
                .foregroundColor(.black)
            }
            .font(.headline)
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if selectedTab == 0 {
                        if recipeVM.ingredients.isEmpty {
                            Text("Keine Zutaten vorhanden")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(recipeVM.ingredients, id: \.id) { ingredient in
                                HStack {
                                    Text("• \(ingredient.name)")
                                        .font(.body)
                                    if let quantity = ingredient.quantity {
                                        Text("(\(quantity, specifier: "%.2f"))") // 🔥 Menge anzeigen
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("Hier könnten die Wirkstoffe stehen...") // 🔹 Falls du Wirkstoffe hinzufügst
                            .font(.body)
                    }
                }
                .padding()
            }
            .toolbar(.hidden, for: .tabBar)
            
            CreateButton(label: "Jetzt zubereiten") {
                prepareRecipe()
            }
            .padding()
        }
        .globalBackground()
        .edgesIgnoringSafeArea(.top)
        .task {
            print("🛠 Lade Zutaten für Rezept: \(recipe.name)")
            await recipeVM.fetchIngredients(for: recipe) // ✅ `$` hinzufügen
            print("✅ Zutaten nach Laden: \($recipeVM.ingredients.count)")
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

#Preview {
    RecipeDetailView(
        recipe: Recipe(
            name: "Heilerde Maske",
            description: "Eine reinigende Maske für fettige, unreine Haut",
            category: [.facialCare, .bodyCare]
        ),
        recipeVM: RecipeViewModel()
    )
}
