//
//  PasswordField.swift
//  Greenly
//
//  Created by Kim Reuter on 20.02.25.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    var isLogin: Bool
    @Binding var passwordErrors: [String]
    
    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField("Password", text: $password)
                    .textContentType(.password)
            } else {
                SecureField("Password", text: $password)
                    .textContentType(.password)
            }
            Button {
                withAnimation { isPasswordVisible.toggle() }
            } label: {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash")
                    .foregroundStyle(.green)
            }
        }
        .authTextFieldStyle()
        .onChange(of: password) { _, newPassword in
            if !isLogin {
                passwordErrors = AuthManager.shared.getPasswordRequirements(newPassword)
            }
        }
    }
}
                  
                  
                  
