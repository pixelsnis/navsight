//
//  SetupView.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import AuthenticationServices
import SwiftUI

struct SetupView: View {
    @Environment(\.colorScheme) private var scheme
    @AppStorage("language") private var language: String = "en"
    
    @State private var vm: ViewModel = .init()
    @StateObject private var player: PlaybackEngine = .init()
    
    var body: some View {
        VStack(spacing: 90) {
            if vm.transitionStage == .signIn {
                Picker("Select language", selection: $language) {
                    ForEach(["en", "hi", "kn"], id: \.self) {
                        Text(vm.languageLabels[$0] ?? "English")
                            .tag($0)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: language) {
                    restartPlayback()
                }
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 1)
            }
            
            VStack(spacing: 36) {
                if vm.transitionStage != .signIn {
                    StageHeader(icon: vm.headerIcon, title: vm.headerTitle, subtitle: vm.headerSubtitle)
                        .frame(maxWidth: .infinity)
                        .opacity((vm.stage != .signIn || vm.stage != .transition) ? 1 : 0)
                        .transition(.opacity)
                }
                
                ZStack {
                    Button {
                        vm.requestLocationAccess()
                    } label: {
                        TTSCircle(player: player, scale: vm.circleScale)
                    }
                    .allowsHitTesting(vm.stage == .location)
                    
                    if vm.stage == .location {
                        LocationGrantButton()
                            .transition(.opacity)
                    } else if vm.stage == .qrCode {
                        InviteQRCode()
                            .transition(.opacity)
                    }
                }
                if vm.transitionStage == .signIn {
                    pageOne()
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom).combined(with: .blurReplace()))
                } else if vm.transitionStage == .location {
                    LocationGrantPromptArrow()
                        .opacity(vm.stage == .location ? 1 : 0)
                        .transition(.move(edge: .bottom).combined(with: .blurReplace()))
                } else if vm.transitionStage == .qrCode {
                    Text("Waiting for account setup...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .transition(.move(edge: .bottom).combined(with: .blurReplace()))
                }
                
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            initState()
        }
    }
    
    private func initState() {
        do {
            try player.load(IntroDialogues.cue)
            print("Loaded player")
            
            try player.play()
        } catch {
            print("Failed to handle init: \(error.localizedDescription)")
        }
    }
    
    private func restartPlayback() {
        do {
            try player.stop()
            
            try player.load(IntroDialogues.cue)
            try player.play()
        } catch {
            print("Failed to restart playback: \(error.localizedDescription)")
        }
    }
    
    private func signIn(_ result: Result<ASAuthorization, any Error>) {
        try? player.stop()
        vm.signIn(result, as: .ward)
    }
    
    @ViewBuilder private func pageOne() -> some View {
        TTSTranscription(player: player)
        
        VStack(spacing: 16) {
            SignInWithAppleButton { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                signIn(result)
            }
            .signInWithAppleButtonStyle(scheme == .light ? .black : .white)
            .frame(height: 42)
            .clipShape(.rect(cornerRadius: 12))
            
            Button {
                
            } label: {
                HStack(spacing: 6) {
                    Text("Or, continue as a Guardian")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            }
        }
        
    }
}

#Preview {
    SetupView()
}
