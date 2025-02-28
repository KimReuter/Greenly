//
//  CategorySection.swift
//  Greenly
//
//  Created by Kim Reuter on 20.02.25.
//

import SwiftUI

struct CategorySection: View {
    let category: RecipeCategory
    let recipes: [Recipe]
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(category.name)
                .font(.title)
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recipes) { recipe in
                        VStack {
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeVM: recipeVM)) {
                                VStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                        .cornerRadius(10)
                                    
                                    Text(recipe.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 160, height: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                            Button(action: {
                                Task {
                                    await recipeVM.toggleFavorite(recipe: recipe)
                                }
                            }) {
                                Image(systemName: recipeVM.isRecipeFavorite(recipe) ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(recipeVM.isRecipeFavorite(recipe) ? .red : .gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


