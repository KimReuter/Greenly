//
//  GreenlyApp.swift
//  Greenly
//
//  Created by Kim Reuter on 09.02.25.
//

import SwiftUI
import FirebaseCore

@main
struct GreenlyApp: App {
    
    @State var authVM: AuthenticationViewModel
    @State var recipeVM: RecipeViewModel
    @State var userVM: UserViewModel
    @State var collectionVM: CollectionViewModel
    
    var body: some Scene {
        WindowGroup {
//            if !authVM.isUserSignedIn {
//                AuthenticationView(authVM: authVM)
//            } else {
            NavigationView(authVM: authVM, recipeVM: recipeVM, userVM: userVM, collectionVM: collectionVM)
//            }
        }
    }
    
    init() {
        FirebaseApp.configure()
        authVM = AuthenticationViewModel()
        recipeVM = RecipeViewModel(imageRepository: ImgurImageRepository(clientID: "6261d10abfac0c8"))
        userVM = UserViewModel()
        collectionVM = CollectionViewModel()
    }
    
}
