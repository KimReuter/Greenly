//
//  ImgurImageRepository.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import Foundation

final class ImgurImageRepository: ImageRepository {
    
    private var clientID: String
    
    init(clientID: String) {
        self.clientID = clientID
    }
    
    func uploadImage(data: Data) async throws -> ImageRef {
        let urlString = "https://api.imgur.com/3/image"
        guard let url = URL(string: urlString) else { throw ImageUploadError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")

        // ✅ Rohdaten senden, keine Base64-Kodierung!
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ImageUploadError.invalidStatusCode(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }

            print("🔄 Imgur API Response Code: \(httpResponse.statusCode)")
            print("📥 Imgur Response Data: \(String(data: data, encoding: .utf8) ?? "Fehlende Daten")")

            guard let response = try? JSONDecoder().decode(UploadResponse.self, from: data) else {
                throw ImageUploadError.responseDecodingFailed
            }

            return ImageRef(id: response.data.deletehash, url: response.data.link)
        } catch {
            print("❌ API-Fehler: \(error.localizedDescription)")
            throw ImageUploadError.networkingError
        }
    }
    
    func deleteImage(_ imageRef: ImageRef) async throws(ImageDeleteError) {
        guard let url = URL(string: "https://api.imgur.com/3/image/\(imageRef.id)") else { throw .noURL }
        
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        
        guard let (_, response) = try? await URLSession.shared.data(for: request) else {
            throw .networkingError
        }

        guard let httpResponse = response as? HTTPURLResponse else { throw .invalidResponseObject }
        guard (200...299).contains(httpResponse.statusCode) else { throw .invalidStatusCode }
    }
}

enum ImageUploadError: LocalizedError {
    case invalidURL
    case networkingError
    case invalidResponseObject
    case invalidStatusCode(statusCode: Int)
    case responseDecodingFailed
    case other(error: any Error)
    
    var errorDescription: String? {
        String(describing: self)
    }
}

enum ImageDeleteError: LocalizedError {
    case noURL
    case networkingError
    case invalidResponseObject
    case invalidStatusCode
    
    var errorDescription: String? {
        String(describing: self)
    }
}
