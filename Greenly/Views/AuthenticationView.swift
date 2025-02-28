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
    @State private var isPasswordVisible = false
    @State private var passwordErrors: [String] = AuthManager.shared.getPasswordRequirements("")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("AuthViewBackground")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    Text(isLogin ? "Login" : "Registrieren")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .transition(.opacity)
                    
                    if !isLogin {
                        TextField("Name", text: $authVM.name)
                            .authTextFieldStyle()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        Color.clear.frame(height: 25)
                    }
                    
                    Section {
                        TextField("E-Mail", text: $authVM.email)
                            .authTextFieldStyle()
                        
                        PasswordField(
                            password: $authVM.password,
                            isPasswordVisible: $isPasswordVisible,
                            isLogin: isLogin,
                            passwordErrors: $passwordErrors
                        )
                        if !isLogin {
                            PasswordRequirement(passwordErrors: passwordErrors)
                        }
                    } footer: {
                        if let errorMessage = authVM.errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .frame(width: 350)
                                .padding()
                        }
                    }
                    CreateButton(label: isLogin ? "Login" : "Registrieren") {
                        isLogin ? authVM.signIn() : authVM.signUp()
                    }
                    .disabled(!passwordErrors.isEmpty && !isLogin)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLogin.toggle()
                            authVM.errorMessage = nil
                        }
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
}
