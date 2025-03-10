//
//  CreateButtonView.swift
//  Greenly
//
//  Created by Kim Reuter on 14.02.25.
//

import SwiftUI

struct CreateButton: View {
    let label: String
    let action: () -> Void

    init(
        label: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
        }
        .font(.headline)
        .foregroundStyle(Color("secondaryColor"))
        .frame(width: 350, height: 55)
        .background(Color("tertiaryColor"))
        .cornerRadius(10)
    }
}

#Preview {
    CreateButton(label: "Test Button") {
        print("Button clicked!")
    }
}
