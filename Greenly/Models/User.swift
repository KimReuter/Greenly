//
//  User.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    
    var name: String
    var email: String
    var signedUpOn: Date
    var profileImageUrl: String?
}
