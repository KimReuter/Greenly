//
//  DifficultyRecipe.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum Difficulty: Codable, CaseIterable {
    
    case easy
    case medium
    case hard
    
    var name: String {
        switch self {
        case .easy: "Einfach"
        case .medium: "Mittel"
        case .hard: "Schwer"
        }
    }
    
}
