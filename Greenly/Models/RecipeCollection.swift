//
//  Collection.swift
//  Greenly
//
//  Created by Kim Reuter on 13.03.25.
//

import Foundation
import FirebaseFirestore

struct RecipeCollection: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    var name: String
    var recipeIDs: [String]
    
}
