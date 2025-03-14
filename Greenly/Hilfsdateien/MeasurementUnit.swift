//
//  MeasurementUnit.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum MeasurementUnit: String, Codable, CaseIterable {
    
    case gram = "gram"
    case milliliter = "milliliter"
    case teaspoon = "teaspoon"
    case tablespoon = "tablespoon"
    case drop = "drop"
    case piece = "piece"
    
    var name: String {
        switch self {
        case .gram: "G"
        case .milliliter: "ML"
        case .teaspoon: "T 🥄"
        case .tablespoon: "E 🥄"
        case .drop: "💧"
        case .piece: "🍕"
        }
    }
    
}
