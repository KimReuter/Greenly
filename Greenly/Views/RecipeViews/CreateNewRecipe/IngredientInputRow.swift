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

            Picker("", selection: $ingredient.unit) {
                ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                    Text(unit.name)
                        .tag(unit)
                        .foregroundStyle(.white)
                }
                
            }
            .pickerStyle(MenuPickerStyle())
            .tint(.white)

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}
