//
//  QRCode.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import SwiftUI

extension SetupView {
    struct InviteQRCode: View {
        @State private var invite: InviteService = .init()
        @State private var qr: UIImage? = nil
        
        var body: some View {
            Group {
                if let qr {
                    Image(uiImage: qr)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .transition(.scale.combined(with: .blurReplace()))
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .foregroundStyle(.black)
                        .transition(.scale.combined(with: .blurReplace()))
                }
            }
            .animation(.default, value: qr != nil)
            .onAppear {
                generate()
            }
        }
        
        private func generate() {
            if invite.invite != nil { return }
            
            Task {
                do {
                    try await invite.create()
                    self.qr = invite.getQRCode()
                    
                    guard let inviteID = invite.invite?.id else { return }
                    
                    DispatchQueue.main.async {
                        Task {
                            await ViewModel.shared.listenToInviteStatus(id: inviteID)
                        }
                    }
                } catch {
                    print("Failed to generate invite: \(error.localizedDescription)")
                }
            }
        }
    }
}
