//
//  User.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import Foundation

struct User: Codable, Identifiable {
    
    var id: String
    var email: String
    var signedUpOn: Date
    
}
