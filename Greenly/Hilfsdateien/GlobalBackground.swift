//
//  GlobalBackground.swift
//  Greenly
//
//  Created by Kim Reuter on 27.02.25.
//

import SwiftUI

struct GlobalBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            Color(Color("background")).ignoresSafeArea()
            content
        }
    }
}

extension View {
    func globalBackground() -> some View {
        modifier(GlobalBackground())
    }
}
