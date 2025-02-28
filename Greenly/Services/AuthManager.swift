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
    
    func signUp(email: String, password: String, name: String) async throws(Error) {
        guard isValidPassword(password) else {
                    throw Error.invalidPassword(reason: getPasswordRequirements(password).joined(separator: ", "))
                }
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            self.user = result.user
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            self.user = auth.currentUser
        } catch {
            throw .signUpFailed(reason: error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws(Error) {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            self.user = result.user
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
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func getPasswordRequirements(_ password: String) -> [String] {
        var errors: [String] = []
        
        if password.count < 6 {
            errors.append("Mindestens 6 Zeichen")
        }
        if password.range(of: "[A-Z]", options: .regularExpression) == nil {
            errors.append("Mindestens 1 Großbuchstabe")
        }
        if password.range(of: "[a-z]", options: .regularExpression) == nil {
            errors.append("Mindestens 1 Kleinbuchstabe")
        }
        if password.range(of: "\\d", options: .regularExpression) == nil {
            errors.append("Mindestens 1 Zahl")
        }
        if password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) == nil {
            errors.append("Mindestens 1 Sonderzeichen")
        }
        
        return errors
    }
    
    enum Error: LocalizedError {
        case signOutFailed(reason: String)
        case signInFailed(reason: String)
        case signUpFailed(reason: String)
        case signUpAnonymouslyFailed(reason: String)
        case invalidPassword(reason: String)
        
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
            case .invalidPassword(let reason):
                "Invalid password: \(reason)"
            }
        }
    }
    
}
