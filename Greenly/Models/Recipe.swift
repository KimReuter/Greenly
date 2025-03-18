//
//  Recipe.swift
//  Greenly
//
//  Created by Kim Reuter on 10.02.25.
//

import Foundation
import FirebaseFirestore

struct Recipe: Codable, Identifiable {
    @DocumentID var id: String?
    
    var name: String
    var description: String
    var category: [RecipeCategory]
    var ingredients: [Ingredient]?
    var imageUrl: String?
    var authorID: String?
    var preparationSteps: [PreparationStepType]?
    
}


