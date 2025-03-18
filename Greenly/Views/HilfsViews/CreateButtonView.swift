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
        .foregroundStyle(Color(.white))
        .frame(width: 350, height: 55)
        .background(Color("buttonPrimary"))
        .cornerRadius(10)
    }
}

#Preview {
    CreateButton(label: "Test Button") {
        print("Button clicked!")
    }
}
