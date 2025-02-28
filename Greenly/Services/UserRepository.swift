//
//  UserRepository.swift
//  Greenly
//
//  Created by Kim Reuter on 14.02.25.
//

import FirebaseFirestore

final class UserRepository {
    
    func insert(id: String, email: String, name: String, createdOn: Date) async throws(Error) -> User {
        let user = User(id: id, name: name, email: email, signedUpOn: createdOn, favoriteRecipeIDs: [])
        do {
            try database.collection("users").document(id).setData(from: user)
        } catch {
            throw .creationFailed
        }
        return try await find(by: id)
    }
    
    func find(by id: String) async throws(Error) -> User {
        do {
            let snapshot = try await database.collection("users").document(id).getDocument()
            return try snapshot.data(as: User.self)
        } catch {
            throw .fetchingFailed
        }
    }
    
    private let database = Firestore.firestore()

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

