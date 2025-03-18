//
//  ImageSelectionView.swift
//  Greenly
//
//  Created by Kim Reuter on 14.03.25.
//

import SwiftUI
import PhotosUI

struct ImageSelectionView: View {
    @Bindable var recipeVM: RecipeViewModel

    var body: some View {
        Section(header: Text("Rezept Bild")) {
            if let image = recipeVM.selectedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            } else {
                Text("Kein Bild ausgewählt")
                    .foregroundColor(.gray)
            }

            PhotosPicker("📸 Bild auswählen", selection: $recipeVM.selectedImageItem)
                .onChange(of: recipeVM.selectedImageItem) {
                    recipeVM.fetchImageFromStorage()
                }
                .foregroundStyle(.white)

            if let uploadedImageURL = recipeVM.uploadedImageURL {
                AsyncImage(url: uploadedImageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }

                Button("❌ Bild löschen") {
                    Task {
                        await recipeVM.deleteImage()
                    }
                }
                .foregroundColor(.red)
            }
        }
    }
}
