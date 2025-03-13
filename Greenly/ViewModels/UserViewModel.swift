//
//  UserViewModel.swift
//  Greenly
//
//  Created by Kim Reuter on 11.03.25.
//
import Foundation
import FirebaseAuth

@Observable
final class UserViewModel {
    var user: User?
    var errorMessage: String?
    private let userRepo = UserRepository() // 🔥 `UserRepository` statt `UserManager`

    // 📤 **Profilbild hochladen**
    func uploadProfileImage(imageData: Data) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "❌ Kein User eingeloggt"
            return
        }
        
        do {
            let imageUrl = try await userRepo.uploadProfileImage(userID: userID, imageData: imageData)
            user?.profileImageUrl = imageUrl // 🔄 UI-Update
            print("✅ Profilbild erfolgreich aktualisiert!")
        } catch {
            errorMessage = "❌ Fehler beim Hochladen: \(error.localizedDescription)"
            print(errorMessage!)
        }
    }
    
    // 📥 **User-Daten abrufen**
    func fetchUserProfile() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        do {
            user = try await userRepo.fetchUserProfile(userID: userID)
            print("✅ User-Daten geladen: \(user?.name ?? "Unbekannt")")
        } catch {
            errorMessage = "❌ Fehler beim Laden des Profils: \(error.localizedDescription)"
            print(errorMessage!)
        }
    }
}
