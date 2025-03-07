//
//  RecipeImageView.swift
//  Greenly
//
//  Created by Kim Reuter on 07.03.25.
//

import SwiftUI

struct RecipeImageView: View {
    let imageUrl: String?
    @State private var imageOpacity: Double = 1

    var body: some View {
        ZStack {
            if let imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                            .clipped()
                            .opacity(imageOpacity)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
    }
    
    private var placeholderImage: some View {
        Color.gray.opacity(0.3)
            .frame(height: UIScreen.main.bounds.height * 0.5)
            .overlay {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
    }
}
