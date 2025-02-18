//
//  AuthenticationView.swift
//  Greenly
//
//  Created by Kim Reuter on 13.02.25.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Bindable var authVM: AuthenticationViewModel
    @State private var isLogin = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("AuthViewBackground")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack {
                    Text(isLogin ? "Login" : "Registrieren")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                    Section {
                        TextField("E-Mail", text: $authVM.email)
                            .authTextFieldStyle()
                        SecureField("Password", text: $authVM.password)
                            .authTextFieldStyle()
                    }
                    CreateButton(label: isLogin ? "Login" : "Registrieren") {
                        isLogin ? authVM.signIn() : authVM.signUp()
                    }
                    Button(action: {
                                    isLogin.toggle() // Umschalten zwischen Login und Registrierung
                                }) {
                                    Text(isLogin ? "Noch keinen Account? Jetzt registrieren!" : "Bereits registriert? Hier einloggen!")
                                        .foregroundColor(.white)
                                        .underline()
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
