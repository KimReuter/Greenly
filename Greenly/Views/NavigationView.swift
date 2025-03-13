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
    @Bindable var userVM: UserViewModel
    @Bindable var collectionVM: CollectionViewModel
    
    @State private var selectedTab = 0
    @State private var isTabBarHidden = false
    
    let tabIcons = ["book.fill", "person.crop.circle"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                
                AllRecipes(recipeVM: recipeVM, collectionVM: collectionVM)
                    .tag(0)
                
                ProfileView(authVM: authVM, recipeVM: recipeVM, userVM: userVM, collectionVM: collectionVM)
                    .tag(1)
            }
            .ignoresSafeArea(.all, edges: .bottom)

            // ⬇️ FloatingTabBar nur anzeigen, wenn isTabBarHidden false ist
            if !isTabBarHidden {
                FloatingTabBar(selectedTab: $selectedTab, tabs: tabIcons)
                    .padding(.bottom, 20)
            }
        }
        .tint(Color("tertiaryColor"))
        .globalBackground()
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \ .self) { index in
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedTab = index
                    }
                }) {
                    VStack {
                        Image(systemName: tabs[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        
                        Circle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.8))
                .shadow(radius: 5)
        )
        .padding(.horizontal, 30)
    }
}


