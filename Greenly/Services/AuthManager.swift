//
//  AuthManager.swift
//  Greenly
//
//  Created by Kim Reuter on 13.02.25.
//

import FirebaseAuth

@Observable

final class AuthManager {
    
    static let shared = AuthManager()
    
    var isUserSignedIn: Bool {
        user != nil
    }
    
    var userID: String? {
        user?.uid
    }
    
    var email: String? {
        user?.email
    }
    
    func signUpAnonymously() async throws(Error) {
        do {
            let result = try await auth.signInAnonymously()
            user = result.user
        } catch {
            throw .signUpAnonymouslyFailed(reason: error.localizedDescription)
        }
        
    }
    
    func signUp(email: String, password: String) async throws(Error) {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
        } catch {
            throw .signUpFailed(reason: error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws(Error) {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
        } catch {
            throw .signInFailed(reason: error.localizedDescription)
        }
    }
    
    func signOut() throws(Error) {
        do {
            try auth.signOut()
            user = nil
        } catch {
            throw .signOutFailed(reason: error.localizedDescription)
        }
    }
    
    private var user: FirebaseAuth.User?
    
    private let auth = Auth.auth()
    
    private func checkAuth() {
        user = auth.currentUser
    }
    
    private init() {
        checkAuth()
    }
    
    enum Error: LocalizedError {
        case signOutFailed(reason: String)
        case signInFailed(reason: String)
        case signUpFailed(reason: String)
        case signUpAnonymouslyFailed(reason: String)
        
        var errorDescription: String? {
            switch self {
            case .signOutFailed(let reason):
                "The sign out failed: \(reason)"
            case .signInFailed(let reason):
                "The sign in failed: \(reason)"
            case .signUpFailed(let reason):
                "The sign up failed: \(reason)"
            case .signUpAnonymouslyFailed(let reason):
                "The anonymous sign up failed: \(reason)"
            }
        }
    }
    
}
