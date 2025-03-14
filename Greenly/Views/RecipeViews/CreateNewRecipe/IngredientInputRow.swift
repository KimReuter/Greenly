//
//  IngredientInputRow.swift
//  Greenly
//
//  Created by Kim Reuter on 14.03.25.
//

import SwiftUI

struct IngredientInputRow: View {
    @Binding var ingredient: IngredientInput
    var onDelete: () -> Void

    var body: some View {
        HStack {
            TextField("Zutat", text: $ingredient.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Menge", value: $ingredient.quantity, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 80)

            Picker("Einheit", selection: $ingredient.unit) {
                ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .pickerStyle(MenuPickerStyle()) // 🎨 Platzsparender als WheelPicker

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}
