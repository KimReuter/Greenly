//
//  IngredientCategory.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum IngredientCategory: Codable, CaseIterable {
    
    case oil
    case butter
    case wax
    case essentialOil
    case powder
    case liquid
    case extract
    case preservative
    case emulsifier
    case colorant
    case different
    
    var name: String {
        switch self {
        case .oil: "Öl"
        case .butter: "Butter"
        case .wax: "Wachs"
        case .essentialOil: "Ätherisches Öl"
        case .powder: "Pulver"
        case .liquid: "Flüssigkeit"
        case .extract: "Extrakt"
        case .preservative: "Konserverungsmittel"
        case .emulsifier: "Emulgator"
        case .colorant: "Färbungsmittel"
        case .different: "Andere"
        }
    }
    
}
