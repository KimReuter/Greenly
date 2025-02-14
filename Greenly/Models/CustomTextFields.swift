//
//  CustomTextFields.swift
//  Greenly
//
//  Created by Kim Reuter on 14.02.25.
//

import SwiftUI

struct AuthTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: 350)
            .padding(.horizontal, 20)
    }
}

extension View {
    func authTextFieldStyle() -> some View {
        self.modifier(AuthTextFieldModifier())
    }
}
