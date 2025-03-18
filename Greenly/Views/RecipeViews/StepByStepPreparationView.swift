//
//  StepByStepPreparationView.swift
//  Greenly
//
//  Created by Kim Reuter on 18.03.25.
//

import SwiftUI

struct StepByStepPreparationView: View {
    var steps: [PreparationStepType]
    @State private var currentStepIndex: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("\(currentStepIndex + 1)/\(steps.count)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Text(steps[currentStepIndex].name)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            HStack {
                Button(action: goBack) {
                    Text("← Zurück")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .disabled(currentStepIndex == 0)
                
                Button(action: goNext) {
                    Text(currentStepIndex == steps.count - 1 ? "Fertig 🎉" : "Weiter →")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Zubereitung")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("backgroundPrimary"))
    }
    
    private func goBack() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    private func goNext() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            dismiss()
        }
    }
}
