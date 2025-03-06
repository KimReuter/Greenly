//
//  UploadViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import SwiftUI
import PhotosUI

@Observable
final class UploadViewModel {
    var selectedImageItem: PhotosPickerItem?
    var selectedImage: Image?
    var selectedImageData: Data?
    
    var imageRepository: ImageRepository = ImgurImageRepository(clientID: "6261d10abfac0c8")
    var uploadedImageRef: ImageRef?
    var uploadedImageURL: URL? {
        guard let imageRef = uploadedImageRef else { return nil }
        return URL(string: imageRef.url)
    }
    
    var errorMessage: String?

    func fetchImageFromStorage() {
        Task {
            do {
                selectedImage = try await selectedImageItem?.loadTransferable(type: Image.self)
                selectedImageData = try await selectedImageItem?.loadTransferable(type: Data.self)
            } catch {
                errorMessage = "Bild konnte nicht geladen werden: \(error.localizedDescription)"
            }
        }
    }
    
    func uploadImage() {
        guard let selectedImageData else {
            errorMessage = "Kein Bild ausgewählt."
            return
        }
        Task {
            do {
                uploadedImageRef = try await imageRepository.uploadImage(data: selectedImageData)
            } catch {
                errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteImage() {
        guard let uploadedImageRef else {
            errorMessage = "Kein Bild zum Löschen."
            return
        }
        Task {
            do {
                try await imageRepository.deleteImage(uploadedImageRef)
                self.uploadedImageRef = nil // Bild löschen
            } catch {
                errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
            }
        }
    }
}
