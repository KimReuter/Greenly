//
//  ProfileButton.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct ProfileButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color("buttonPrimary"))
                    .padding()
                    .background(Circle().fill(Color.white))
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("buttonPrimary")))
            .shadow(radius: 2)
        }
    }
}
