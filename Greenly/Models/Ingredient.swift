//
//  Zutat.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import Foundation
import FirebaseFirestore

struct Ingredient: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
//    var quantity: Double
//    var unit: MeasurementUnit
//    var category: IngredientCategory
//    var meltingPoint: Double?
//    var shelfLive: String?
//    var origin: String?
//    var description: String?
//    var benefits: [String]?
//    var warnings: [String]?
    
}
