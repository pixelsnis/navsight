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
    
    @State private var vm: ViewModel = .shared
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
                    .frame(height: vm.stage == .guardian ? 90 : 1)
            }
            
            VStack(spacing: vm.stage == .guardian ? 16 : 36) {
                if [SetupStage.signIn, SetupStage.guardian, SetupStage.scan].contains(where: { $0 == vm.stage }) == false {
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
                    
                    if vm.stage == .guardian {
                        Image(systemName: "shield.lefthalf.fill")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.black)
                            .transition(.opacity)
                    } else if vm.stage == .location {
                        LocationGrantButton()
                            .transition(.opacity)
                    } else if vm.stage == .qrCode {
                        InviteQRCode()
                            .transition(.opacity)
                    } else if vm.stage == .scan {
                        ScannerView { result in 
                            vm.processInvite(result)
                        }
                        .transition(.opacity)
                    } else if vm.stage == .complete {
                        Image(systemName: "checkmark")
                            .font(.system(size: 90, weight: .semibold))
                            .foregroundStyle(.black)
                            .transition(.scale.combined(with: .blurReplace()))
                    }
                }
                if [SetupStage.signIn, SetupStage.guardian, SetupStage.scan].contains(where: { $0 == vm.stage || $0 == vm.transitionStage }) {
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
                } else if vm.stage == .complete {
                    Button {
                        
                    } label: {
                        Text("Finish setup")
                            .foregroundStyle(.black)
                            .containAsButton()
                    }
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
    
    private func toggleGuardianViews() {
        if vm.stage == .signIn {
            vm.navigate(to: .guardian, transition: false)
            try? player.stop()
        } else if vm.stage == .guardian {
            vm.navigate(to: .signIn, transition: false)
            restartPlayback()
        }
    }
    
    private func signIn(_ result: Result<ASAuthorization, any Error>) {
        try? player.stop()
        vm.signIn(result, as: vm.stage == .guardian ? .guardian : .ward)
    }
    
    @ViewBuilder private func pageOne() -> some View {
        VStack(spacing: 36) {
            if (vm.stage != .guardian && vm.stage != .scan) {
                TTSTranscription(player: player)
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    Text(vm.transitionStage == .scan ? "Scan your ward's invite QR code" : "Set up as a Guardian")
                        .font(.headline)
                        .contentTransition(.numericText())
                    Text(vm.transitionStage == .scan ? "Make sure they have Navsight installed and are signed in." :"If you’ve already set up your ward’s device, continue here")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                }
            }
            
            if vm.transitionStage != .scan {
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
                        toggleGuardianViews()
                    } label: {
                        Group {
                            if vm.transitionStage == .guardian {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                    Text("Go back")
                                }
                                .transition(.blurReplace())
                            } else {
                                HStack(spacing: 6) {
                                    Text("Or, continue as a Guardian")
                                    Image(systemName: "chevron.right")
                                }
                                .transition(.blurReplace())
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    SetupView()
}
