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
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.blue))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(radius: 2)
        }
    }
}
