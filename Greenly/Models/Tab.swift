//
//  Tab.swift
//  Greenly
//
//  Created by Kim Reuter on 28.02.25.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case home = "house"
    case recipes = "book.fill"
    case community = "person.3"
    case settings = "gearshape"
    
    var title: String {
        switch self {
        case .home: "Home"
        case .recipes: "Recipes"
        case .community: "Community"
        case .settings: "Settings"
        }
    }
}
