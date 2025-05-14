//
//  TTSTranscription.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import Combine
import SwiftUI

struct TTSTranscription: View {
    @ObservedObject var player: PlaybackEngine
    
    init(player: PlaybackEngine) {
        self.player = player
    }
    
    @State private var cancellables: [AnyCancellable] = []
    @State private var shownTranscription: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            if let shownTranscription {
                Text(shownTranscription)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: shownTranscription)
        .frame(height: 120)
        .onAppear {
            let cancellable = player.transcriptionSubject.sink { value in
                if shownTranscription == nil {
                    shownTranscription = value
                    return
                }
                
                shownTranscription = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: {
                    shownTranscription = value
                })
            }
            
            cancellables.append(cancellable)
        }
    }
}

#Preview {
    SetupView()
}
