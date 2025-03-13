//
//  UserRepository.swift
//  Greenly
//
//  Created by Kim Reuter on 14.02.25.
//

import FirebaseFirestore
import FirebaseStorage

final class UserRepository {
    
    func insert(id: String, email: String, name: String, createdOn: Date) async throws(Error) -> User {
        let user = User(id: id, name: name, email: email, signedUpOn: createdOn)
        do {
            try db.collection("users").document(id).setData(from: user)
        } catch {
            throw .creationFailed
        }
        return try await find(by: id)
    }
    
    func find(by id: String) async throws(Error) -> User {
        do {
            let snapshot = try await db.collection("users").document(id).getDocument()
            return try snapshot.data(as: User.self)
        } catch {
            throw .fetchingFailed
        }
    }
    
    func uploadProfileImage(userID: String, imageData: Data) async throws -> String {
            let storageRef = storage.reference().child("profileImages/\(userID).jpg")

            // 🔥 Bild hochladen
            _ = try await storageRef.putData(imageData)

            // 🔥 Download-URL abrufen
            let downloadURL = try await storageRef.downloadURL()
            print("✅ Profilbild hochgeladen: \(downloadURL.absoluteString)")

            // 🔥 URL in Firestore speichern
            try await db.collection("users").document(userID).updateData(["profileImageUrl": downloadURL.absoluteString])

            return downloadURL.absoluteString
        }

        // 📥 **User-Daten abrufen**
        func fetchUserProfile(userID: String) async throws -> User {
            let snapshot = try await db.collection("users").document(userID).getDocument()
            return try snapshot.data(as: User.self)
        }
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    enum Error: LocalizedError {
        case fetchingFailed
        case creationFailed
        
        var errorDescription: String? {
            switch self {
            case .creationFailed:
                "The user creation failed."
            case .fetchingFailed:
                "The fetching of the user failed."
            }
        }
    }
}

