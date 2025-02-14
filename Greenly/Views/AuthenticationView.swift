//
//  AuthenticationView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.02.25.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Bindable var authVM: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("AuthViewBackground")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack {
                    Section {
                        TextField("E-Mail", text: $authVM.email)
                            .authTextFieldStyle()
                        TextField("Password", text: $authVM.password)
                            .authTextFieldStyle()
                    }
                    CreateButton(label: "Login") {
                        authVM.signIn()
                    }
                    
                }
                .padding()
            }
        }
    }
}

#Preview {
    AuthenticationView(authVM: AuthenticationViewModel())
    //        .environment(AuthenticationViewModel())
}
