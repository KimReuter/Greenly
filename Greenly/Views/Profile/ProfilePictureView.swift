//
//  ProfilePictureView.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//

import SwiftUI
import PhotosUI

struct ProfilePictureView: View {
    @Bindable var userVM: UserViewModel
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        VStack {
            // 📷 **Profilbild als Button**
            PhotosPicker(selection: $selectedImageItem) {
                ZStack {
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if let imageUrl = userVM.user?.profileImageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }
            }
            .buttonStyle(.plain) // Verhindert den Standard-Button-Look
            .onChange(of: selectedImageItem) {
                Task {
                    if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        await userVM.uploadProfileImage(imageData: data)
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            Task {
                await userVM.fetchUserProfile()
            }
        }
    }
}
