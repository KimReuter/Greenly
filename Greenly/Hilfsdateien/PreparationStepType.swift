//
//  PreparationStepType.swift
//  Greenly
//
//  Created by Kim Reuter on 18.02.25.
//

import Foundation

enum PreparationStepType: String, Codable, CaseIterable {
    
    // Vorbereitung
    case gatherIngredients
    case weighIngredients
    case prepareWorkstation
    case sterilizeEquipment
    
    // Erhitzen & Schmelzen
    case meltOils
    case meltButters
    case meltWaxes
    case heatWaterPhase
    
    // Mischen & Emulgieren
    case mixPowders
    case blendLiquids
    case emulsify
    case useHandMixer
    case useStickBlender
    
    // Abkühlen & Stabilisieren
    case coolDown
    case stabilizeMixture
    case adjustPH
    
    // Hinzufügen von Inhaltsstoffen
    case addEssentialOils
    case addPreservatives
    case addActives
    case addFragrance
    case addColorant
    
    // Konsistenz prüfen & Anpassen
    case checkConsistency
    case adjustViscosity
    case addThickener
    case addLiquid
    
    // Abfüllen & Verpacken
    case fillIntoContainers
    case removeAirBubbles
    case sealContainers
    case labelAndStore
    
    // Reifezeit & Endkontrolle
    case letProductSet
    case cureSoap
    case finalCheck
    
    // Reinigung & Aufräumen
    case cleanEquipment
    case disposeWasteProperly
    
    var name: String {
        switch self {
        case .gatherIngredients: "Zutaten vorbereiten"
        case .weighIngredients: "Zutaten abwiegen"
        case .prepareWorkstation: "Arbeitsplatz vorbereiten"
        case .sterilizeEquipment: "Geräte sterilisieren"
            
        case .meltOils: "Öle schmelzen"
        case .meltButters: "Butter schmelzen"
        case .meltWaxes: "Wachse schmelzen"
        case .heatWaterPhase: "Wasserphase erhitzen"
            
        case .mixPowders: "Pulver vermengen"
        case .blendLiquids: "Flüssigkeiten mischen"
        case .emulsify: "Emulgieren"
        case .useHandMixer: "Handmixer verwenden"
        case .useStickBlender: "Stabmixer verwenden"
            
        case .coolDown: "Abkühlen lassen"
        case .stabilizeMixture: "Mischung stabilisieren"
        case .adjustPH: "pH-Wert anpassen"
            
        case .addEssentialOils: "Ätherische Öle hinzufügen"
        case .addPreservatives: "Konservierungsstoffe hinzufügen"
        case .addActives: "Wirkstoffe hinzufügen"
        case .addFragrance: "Duftstoffe hinzufügen"
        case .addColorant: "Farbstoff hinzufügen"
            
        case .checkConsistency: "Konsistenz überprüfen"
        case .adjustViscosity: "Viskosität anpassen"
        case .addThickener: "Verdickungsmittel hinzufügen"
        case .addLiquid: "Flüssigkeit hinzufügen"
            
        case .fillIntoContainers: "In Behälter abfüllen"
        case .removeAirBubbles: "Luftblasen entfernen"
        case .sealContainers: "Behälter verschließen"
        case .labelAndStore: "Beschriften & lagern"
            
        case .letProductSet: "Produkt setzen lassen"
        case .cureSoap: "Seife reifen lassen"
        case .finalCheck: "Endkontrolle"
            
        case .cleanEquipment: "Geräte reinigen"
        case .disposeWasteProperly: "Abfälle fachgerecht entsorgen"
        }
    }
}
