//
//  ProgressCard.swift
//  Greenly
//
//  Created by Kim Reuter on 02.03.25.
//

import SwiftUI

struct ProgressCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 80)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
    }
}
