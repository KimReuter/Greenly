//
//  AuthenticationViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 13.02.25.
//

import Foundation
import RegexBuilder

@Observable
final class AuthenticationViewModel {
    
    var user: User?
    var errorMessage: String?
    var email: String = ""
    var password: String = "" 
    var name: String = ""
    var isLogin = true
    
    var isUserSignedIn: Bool {
        AuthManager.shared.isUserSignedIn
    }
    
    func signOut() {
        Task {
            try? AuthManager.shared.signOut()
        }
    }
    
    func signUp() {
        guard AuthManager.shared.isValidPassword(password) else {
            errorMessage = "Passwort erfüllt nicht alle Anforderungen"
            return
        }
        Task {
            do {
                try await AuthManager.shared.signUp(email: email, password: password, name: name)
                let userID = AuthManager.shared.userID!
                let email = AuthManager.shared.email!

                self.user = try await userRepository.insert(id: userID, email: email, name: name, createdOn: .now)
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
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    
    private let userRepository = UserRepository()

}
