//
//  PreparationStepPickerView.swift
//  Greenly
//
//  Created by Kim Reuter on 18.03.25.
//
import SwiftUI

struct PreparationStepPickerView: View {
    @Binding var selectedSteps: [PreparationStepType]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("🔪 Vorbereitung")) {
                    preparationStepRow(for: [.gatherIngredients, .weighIngredients, .prepareWorkstation, .sterilizeEquipment])
                }
                
                Section(header: Text("🔥 Erhitzen & Schmelzen")) {
                    preparationStepRow(for: [.meltOils, .meltButters, .meltWaxes, .heatWaterPhase])
                }
                
                Section(header: Text("🌀 Mischen & Emulgieren")) {
                    preparationStepRow(for: [.mixPowders, .blendLiquids, .emulsify, .useHandMixer, .useStickBlender])
                }
                
                Section(header: Text("❄️ Abkühlen & Stabilisieren")) {
                    preparationStepRow(for: [.coolDown, .stabilizeMixture, .adjustPH])
                }
                
                Section(header: Text("🧪 Hinzufügen von Inhaltsstoffen")) {
                    preparationStepRow(for: [.addEssentialOils, .addPreservatives, .addActives, .addFragrance, .addColorant])
                }
                
                Section(header: Text("🔬 Konsistenz prüfen & Anpassen")) {
                    preparationStepRow(for: [.checkConsistency, .adjustViscosity, .addThickener, .addLiquid])
                }
                
                Section(header: Text("🫙 Abfüllen & Verpacken")) {
                    preparationStepRow(for: [.fillIntoContainers, .removeAirBubbles, .sealContainers, .labelAndStore])
                }
                
                Section(header: Text("⏳ Reifezeit & Endkontrolle")) {
                    preparationStepRow(for: [.letProductSet, .cureSoap, .finalCheck])
                }
                
                Section(header: Text("🧼 Reinigung & Aufräumen")) {
                    preparationStepRow(for: [.cleanEquipment, .disposeWasteProperly])
                }
            }
            .navigationTitle("Zubereitungsschritte")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Fertig")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    /// Hilfsfunktion: Erstellt Zeilen für die Schritte in einer Kategorie
    func preparationStepRow(for steps: [PreparationStepType]) -> some View {
        ForEach(steps, id: \.self) { step in
            MultipleSelectionRow(title: step.name, isSelected: selectedSteps.contains(step), color: selectedSteps.contains(step) ? .white : .gray) {
                if selectedSteps.contains(step) {
                    selectedSteps.removeAll { $0 == step }
                } else {
                    selectedSteps.append(step)
                }
            }
        }
    }
}
