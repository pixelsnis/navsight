//
//  ButtonContainer.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import SwiftUI

struct ButtonContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.accent)
            }
            .foregroundStyle(.black)
    }
}

extension View {
    func containAsButton() -> some View {
        self.modifier(ButtonContainer())
    }
}
