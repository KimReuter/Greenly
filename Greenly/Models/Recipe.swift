//
//  Recipe.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import Foundation
import SwiftUICore

struct Recipe: Codable, Identifiable {
    
    var id: UUID
    var name: String
    var description: String
    var category: RecipeCategory
    var author: String
    var ingredients: [Ingredient]
    var preparationTime: Int
    var difficulty: Difficulty
    var preparationSteps: [PreparationStepType]
    var picture: Data
    var tags: [String]
    
}
