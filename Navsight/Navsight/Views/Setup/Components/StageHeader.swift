//
//  StageHeader.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import SwiftUI

extension SetupView {
    struct StageHeader: View {
        var icon: String?
        var title: String
        var subtitle: String
        
        var body: some View {
            VStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                    .font(.largeTitle.bold())
                    .contentTransition(.symbolEffect(.replace))
                    .transition(.scale.combined(with: .blurReplace()))
                }
                
                VStack(spacing: 0) {
                    Text(title)
                        .font(.headline)
                        .contentTransition(.numericText())
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                }
            }
            .animation(.default, value: icon)
        }
    }
}
