//
//  RecipeCategory.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum RecipeCategory: String, Codable, CaseIterable, Hashable {
    
    case facialCare = "facialCare"
    case hairCare = "hairCare"
    case bodyCare = "bodyCare"
    case handAndFootCare = "handAndFootCare"
    case makeup = "makeup"
    case bathAndWelness = "bathAndWelness"
    case sunProtectionAndAfterSun = "sunProtectionAndAfterSun"
    case perfumesAndFragrances = "perfumesAndFragrances"
    
    case quickAndEasy = "quickAndEasy"
    case beginnerFriendly = "beginnerFriendly"
    case childFriendly = "childFriendly"
    case perfectForGifting = "perfectForGifting"
    case outdoorFriendly = "outdoorFriendly"
    case forSensitiveSkin = "forSensitiveSkin"
    case longLasting = "longLasting"
    case highlyEfficient = "highlyEfficient"
    
    
    var name: String {
        switch self {
        case .facialCare: "Gesichtspflege"
        case .hairCare: "Haarpflege"
        case .bodyCare: "Körperpflege"
        case .handAndFootCare: "Hand- & Fufpflege"
        case .makeup: "Make-Up"
        case .bathAndWelness: "Bad & Welness"
        case .sunProtectionAndAfterSun: "Sonnenschutz & After-Sun"
        case .perfumesAndFragrances: "Parfums"
        case .quickAndEasy: "Schnell & Einfach"
        case .beginnerFriendly: "Für Anfänger"
        case .childFriendly: "Kinderfreundlich"
        case .perfectForGifting: "Zum Verschenken"
        case .outdoorFriendly: "Outdoor - tauglich"
        case .forSensitiveSkin: "Sensible Haut"
        case .longLasting: "Länger haltbar"
        case .highlyEfficient: "Besonders ergiebig"
        }
    }
    
}
