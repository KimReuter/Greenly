//
//  RecipeCategory.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum RecipeCategory: Codable, CaseIterable {
    
    case facialCare
    case hairCare
    case bodyCare
    case handAndFootCare
    case makeup
    case bathAndWelness
    case sundProtectionAndAfterSun
    case perfumesAndFragrances
    
    var name: String {
        switch self {
        case .facialCare: "Gesichtspflege"
        case .hairCare: "Haarpflege"
        case .bodyCare: "Körperpflege"
        case .handAndFootCare: "Hand- & Fufpflege"
        case .makeup: "Make-Up"
        case .bathAndWelness: "Bad & Welness"
        case .sundProtectionAndAfterSun: "Sonnenschutz & After-Sun"
        case .perfumesAndFragrances: "Parfums"
        }
    }
    
}
