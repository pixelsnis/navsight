//
//  WardMainView.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import SwiftUI

struct WardMainView: View {
    @AppStorage("intro_finished") private var introFinished: Bool = false
    
    @State private var vm: ViewModel = .init()
    @State private var player: PlaybackEngine = .init()
    
    @GestureState private var isTappedDown = false
    
    // MARK: Animation variables
    @State private var scaleUp: Bool = false
    
    var body: some View {
        let tapDownGesture = DragGesture(minimumDistance: 0)
        .updating($isTappedDown) { _, tapped, _ in
            tapped = true
            try? self.player.stop()
        }
        
        let longPressGesture = LongPressGesture(minimumDuration: 1)
            .onEnded { finished in
                if !finished { return }
                
                Task {
                    await vm.queryLocation { cue in
                        onCueLoaded(cue)
                    }
                }
            }
        
        VStack(spacing: 36) {
            Spacer()
            
            TTSCircle(player: player)
                .scaleEffect(scaleUp ? 1 : 0)
                .scaleEffect(isTappedDown ? 0.9 : 1)
                .animation(.default, value: isTappedDown)
                .gesture(tapDownGesture.simultaneously(with: longPressGesture))
            
            TTSTranscription(player: player)
            
            Spacer()
            
            Text(vm.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.default, value: vm.status)
        }
        .padding(.horizontal)
        .onAppear {
            initialize()
        }
    }
    
    private func initialize() {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: {
            withAnimation(.default) {
                scaleUp = true
            }
        })
        
        if !introFinished {
            try? player.load(OnboardingDialogues.cue)
            try? player.play(onFinishPlayback: {
                UserDefaults.standard.set(true, forKey: "intro_finished")
            })
            
            return
        }
    }
    
    private func onCueLoaded(_ cue: AudioCue) {
        
    }
}

#Preview {
    WardMainView()
}
