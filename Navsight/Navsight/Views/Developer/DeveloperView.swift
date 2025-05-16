//
//  DeveloperView.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import SwiftUI

struct DeveloperView: View {
    @State private var sfx: SFXPlayer = .init()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Views") {
                    NavigationLink("Ward View", value: "ward")
                    NavigationLink("Guardian View", value: "guardian")
                }
                
                Section("SFX") {
                    Button("Play click down", systemImage: "play.fill") {
                        sfx.playActivationInSound()
                    }
                    
                    Button("Play click up", systemImage: "play.fill") {
                        sfx.playActivationOutSound()
                    }
                    
                    Button("Toggle thinking sound", systemImage: "play.fill") {
                        if (sfx.thinkingPlayer?.isPlaying == true) {
                            sfx.stopThinkingSound()
                            return
                        }
                        
                        sfx.playThinkingSound()
                    }
                }
            }
            .navigationTitle("Navsight Dev")
            .navigationDestination(for: String.self) { path in
                if path == "ward" {
                    WardMainView()
                } else if path == "guardian" {
                    GuardianMainView()
                } else {
                    ContentUnavailableView("Not found", systemImage: "questionmark.app.dashed")
                }
            }
        }
        .onAppear {
            do {
                try sfx.initialize()
            } catch {
                print("Failed to initialize SFX player: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    DeveloperView()
}
