//
//  UploadView.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @Bindable var uploadVM = UploadViewModel()

    var body: some View {
        VStack {
            PhotosPicker("Bild auswählen", selection: $uploadVM.selectedImageItem)
                .onChange(of: uploadVM.selectedImageItem) {
                    uploadVM.fetchImageFromStorage()
                }
            
            if let image = uploadVM.selectedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Button("📤 Hochladen") {
                    uploadVM.uploadImage()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let url = uploadVM.uploadedImageURL {
                Text("Bild hochgeladen! ✅")
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit().frame(width: 100, height: 100)
                } placeholder: {
                    Image(systemName: "photo.artframe")
                }
                Button("🗑 Löschen") {
                    uploadVM.deleteImage()
                }
                .buttonStyle(.bordered)
            }
            
            if let error = uploadVM.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    UploadView()
}
