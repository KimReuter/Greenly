//
//  AuthenticationViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 13.02.25.
//

import Foundation
import Observation

@Observable
final class AuthenticationViewModel {
    
    var user: User?
    var errorMessage: String?
    var email: String = ""
    var password: String = ""
    
    var isUserSignedIn: Bool {
        AuthManager.shared.isUserSignedIn
    }
    
    func signOut() {
        Task {
            try? AuthManager.shared.signOut()
        }
    }
    
    func signUp() {
        Task {
            do {
                try await AuthManager.shared.signUp(email: email, password: password)
                let userID = AuthManager.shared.userID!
                let email = AuthManager.shared.email!
                self.user = try await userRepository.insert(id: userID, email: email, createdOn: .now)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await AuthManager.shared.signIn(email: email, password: password)
                let userID = AuthManager.shared.userID!
                user = try await userRepository.find(by: userID)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    init() {
        _ = AuthManager.shared
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        Task {
            do {
                if let userID = AuthManager.shared.userID {
                    user = try await userRepository.find(by: userID)
                }
            } catch {
                errorMessage = "User is not signed in."
            }
        }
    }
    
    private let userRepository = UserRepository()

}
