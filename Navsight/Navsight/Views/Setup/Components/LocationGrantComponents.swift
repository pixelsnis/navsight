//
//  LocationGrantComponents.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import SwiftUI

extension SetupView {
    struct LocationGrantButton: View {
        var body: some View {
            VStack(spacing: 0) {
                Text("Tap to grant access")
                Text("Stored securely, encrypted at-rest.")
                    .font(.footnote)
                    .opacity(0.5)
            }
            .foregroundStyle(.black)
        }
    }
    
    struct LocationGrantPromptArrow: View {
        @State private var moveUp = false
        
        var body: some View {
            Image(systemName: "arrow.up")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .offset(y: moveUp ? -5 : 0) // Slide up/down
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: moveUp
                )
                .onAppear {
                    moveUp = true
                }
        }
    }
}
