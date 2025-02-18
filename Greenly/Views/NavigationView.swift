//
//  NavigationView.swift
//  Greenly
//
//  Created by Kim Reuter on 17.02.25.
//

import SwiftUI

struct NavigationView: View {
    
    @Bindable var authVM: AuthenticationViewModel
    @Bindable var recipeVM: RecipeViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }
            AllRecipes()
                .tabItem {
                    Image(systemName: "leaf")
                }
                .environment(recipeVM)
        }
    }
}

#Preview {
    NavigationView(authVM: AuthenticationViewModel(), recipeVM: RecipeViewModel())
}
