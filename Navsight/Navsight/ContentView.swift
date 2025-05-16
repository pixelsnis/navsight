//
//  ContentView.swift
//  Navsight
//
//  Created by Aneesh on 10/5/25.
//

import GoogleSignIn
import SwiftUI

struct ContentView: View {
    @AppStorage("signedIn") private var signedIn: Bool = false
    @AppStorage("role") private var role: String = "undetermined"
    
    var body: some View {
        Group {
            if signedIn {
                Group {
                    if role == "ward" {
                        WardMainView()
                    } else if role == "guardian" {
                        GuardianMainView()
                    } else {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .blurReplace()))
            } else {
                SetupView()
                    .transition(.move(edge: .top).combined(with: .blurReplace()))
            }
        }
        .animation(.default, value: signedIn)
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

#Preview {
    ContentView()
}
