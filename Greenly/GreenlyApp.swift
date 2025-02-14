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
    
    var body: some Scene {
        WindowGroup {
            if !authVM.isUserSignedIn {
                AuthenticationView(authVM: authVM)
            } else {
                HomeView()
            }
        }
    }
    
    init() {
        FirebaseApp.configure()
        authVM = AuthenticationViewModel()
    }
    
}
