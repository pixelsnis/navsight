//
//  TTSCircle.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import SwiftUI

struct TTSCircle: View {
    @ObservedObject var player: PlaybackEngine
    var scale: Double
    var namespace: Namespace.ID?
    
    init(player: PlaybackEngine, scale: Double = 1.0, namespace: Namespace.ID? = nil) {
        self.player = player
        self.scale = scale
        self.namespace = namespace
    }
    
    @Namespace private var placeholderNamespace
    
    // MARK: Computed properties
    private var audioReactiveScale: Double {
        // Clamp to avoid weird values from silence
        let clamped = max(0.0001, min(player.linearLevel, 1.0))
        
        // Apply logarithmic damping curve
        let damped = log10(clamped * 9 + 1) // maps [0.0001, 1.0] -> [0.0, 1.0]
        
        // Scale to desired output range: 1.0 to 1.3
        let scale = 1.0 + (damped * 0.75)
        
        return scale
    }
    
    var body: some View {
        Circle()
            .fill(.accent)
            .matchedGeometryEffect(id: "tts-circle", in: namespace ?? placeholderNamespace)
            .frame(width: 180 * scale, height: 180 * scale)
            .scaleEffect(audioReactiveScale)
            .animation(.easeInOut(duration: 0.2), value: audioReactiveScale)
    }
}
