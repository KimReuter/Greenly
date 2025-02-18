//
//  MeasurementUnit.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum MeasurementUnit: Codable, CaseIterable {
    
    case gram
    case milliliter
    case teaspoon
    case tablespoon
    case drop
    case piece
    
    var name: String {
        switch self {
        case .gram: "Gramm"
        case .milliliter: "Milliliter"
        case .teaspoon: "Teelöffel"
        case .tablespoon: "Esslöffel"
        case .drop: "Tropfen"
        case .piece: "Stück"
        }
    }
    
}
