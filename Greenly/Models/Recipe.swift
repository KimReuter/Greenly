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
    //    var author: String
    //    var preparationTime: Int
    //    var difficulty: Difficulty
    //    var preparationSteps: [PreparationStepType]
    //    var pictureURL: String?
    //    var tags: [String]
    //    var createdByAdmin: Bool
    
}


