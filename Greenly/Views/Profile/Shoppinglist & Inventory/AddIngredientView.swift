//
//  AddIngredientView.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import SwiftUI

struct AddIngredientView: View {
    @Bindable var recipeVM: RecipeViewModel
    @State private var newItem: String = ""
    @State private var quantity: Double = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var unit: MeasurementUnit = .gram  // 🔥 Standardwert auf "Gramm"

    var isValidInput: Bool {
        !newItem.trimmingCharacters(in: .whitespaces).isEmpty && quantity > 0
    }

    var body: some View {
        HStack {
            TextField("Zutat hinzufügen...", text: $newItem)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Menge", value: $quantity, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // 🔥 Kicker für Maßeinheit
            Picker("", selection: $unit) {
                ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .pickerStyle(MenuPickerStyle()) // 🎨 Dropdown-Style für bessere Optik
            .frame(width: 100)

            Button {
                if isValidInput {
                    Task {
                        let ingredient = Ingredient(name: newItem, quantity: quantity, unit: unit)
                        await recipeVM.addToShoppingList(ingredient, missingQuantity: quantity)
                        newItem = ""  // Zurücksetzen nach erfolgreichem Hinzufügen
                        quantity = 0
                    }
                } else {
                    alertMessage = "Bitte gib einen Namen ein und eine Menge größer als 0."
                    showAlert = true
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(isValidInput ? .green : .gray)
                    .font(.title)
            }
            .disabled(!isValidInput) // Button deaktiviert, wenn Eingabe ungültig ist
        }
        .padding()
        .alert("Fehlende Eingabe", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
