//
//  LocationBlinker.swift
//  Navsight
//
//  Created by Aneesh on 16/5/25.
//

import Combine
import SwiftUI

struct LocationBlinker: View {
    var live: Bool = false
    
    @State private var scale: Double = 1.0
    @State private var opacity: Double = 1.0
    
    @State private var cancellables: [AnyCancellable] = []
    
    var body: some View {
        Circle()
            .fill(.orange)
            .frame(width: 16, height: 16)
            .shadow(color: .orange, radius: live ? 6 : 0)
            .animation(.default, value: live)
            .background {
                ZStack {
                    Circle()
                    .fill(.clear)
                    .stroke(.orange, style: .init(lineWidth: 0.1))
                    .opacity(opacity)
                    .scaleEffect(scale)

                    Circle()
                    .fill(.clear)
                    .stroke(.orange, style: .init(lineWidth: 0.5))
                    .opacity(opacity)
                    .scaleEffect(0.5)
                    .scaleEffect(scale)
                }
            }
            .onAppear {
                let timer = Timer.publish(every: 3, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        scale = 1.0
                        opacity = 1.0
                        
                        withAnimation(.easeOut(duration: 3)) {
                            scale = 5.0
                            opacity = 0
                        }
                    }
                
                cancellables.append(timer)
            }
    }
}

#Preview {
    LocationBlinker()
}
