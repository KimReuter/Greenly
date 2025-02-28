//
//  PasswordRequirement.swift
//  Greenly
//
//  Created by Kim Reuter on 20.02.25.
//

import SwiftUI

struct PasswordRequirement: View {
        let passwordErrors: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            passwordRequirement("Mindestens 6 Zeichen", condition: !passwordErrors.contains("Mindestens 6 Zeichen"))
            passwordRequirement("Mindestens 1 Großbuchstabe", condition: !passwordErrors.contains("Mindestens 1 Großbuchstabe"))
            passwordRequirement("Mindestens 1 Kleinbuchstabe", condition: !passwordErrors.contains("Mindestens 1 Kleinbuchstabe"))
            passwordRequirement("Mindestens 1 Zahl", condition: !passwordErrors.contains("Mindestens 1 Zahl"))
            passwordRequirement("Mindestens 1 Sonderzeichen", condition: !passwordErrors.contains("Mindestens 1 Sonderzeichen"))
        }
    }
    
    private func passwordRequirement(_ text: String, condition: Bool) -> some View {
        HStack {
            Image(systemName: condition ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(condition ? .green : .red)
            Text(text)
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
}


