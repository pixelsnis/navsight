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
    @State private var sfx: SFXPlayer = .init()
    
    @State private var isTappedDown: Bool = false
    
    // MARK: Animation variables
    @State private var scaleUp: Bool = false
    
    var body: some View {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if vm.querying { return }
                
                if !isTappedDown {
                    isTappedDown = true
                    sfx.playActivationInSound()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1)), execute: {
                        if isTappedDown {
                            isTappedDown = false
                        }
                    })
                }
            }
            .onEnded { _ in
                if isTappedDown {
                    isTappedDown = false
                }
            }
        
        let longPressGesture = LongPressGesture(minimumDuration: 1)
            .onEnded { succeeded in
                if succeeded && vm.querying == false {
                    startQuery()
                }
            }
        
        VStack(spacing: 36) {
            Spacer()
            
            TTSCircle(player: player)
                .scaleEffect(scaleUp ? 1 : 0)
                .scaleEffect(isTappedDown ? 0.9 : 1)
                .animation(.default, value: isTappedDown)
                .gesture(gesture.simultaneously(with: longPressGesture))
                .sensoryFeedback(.selection, trigger: isTappedDown)
                .sensoryFeedback(.success, trigger: vm.successVibrations)
                .allowsHitTesting(vm.querying == false)
            
            TTSTranscription(player: player)
            
            Spacer()
            
            Text(vm.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
                .animation(.default, value: vm.status)
        }
        .onChange(of: isTappedDown) {
            vm.status = isTappedDown ? "Release to ask" : "Hold down to start"
        }
        .padding(.horizontal)
        .onAppear {
            initialize()
        }
    }
    
    private func initialize() {
        try? sfx.initialize()
        
        DispatchQueue.main.async {
            Task {
                await vm.startLocationService()
            }
        }
        
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
    
    private func startQuery(ignoringLocationCaller: Bool = false) {
        isTappedDown = false
        sfx.playActivationOutSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1)), execute: {
            sfx.playThinkingSound()
        })
        
        Task {
            await vm.queryLocation { cue in
                onCueLoaded(cue)
            }
        }
    }
    
    @MainActor
    private func onCueLoaded(_ cue: AudioCue) {
        do {
            if player.player?.isPlaying == true {
                try player.stop()
            }
            
            sfx.stopThinkingSound()
            
            try player.load(cue)
            try player.play {
                vm.status = "Hold down to start"
            }
        } catch {
            print("Failed to load cue: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WardMainView()
}
