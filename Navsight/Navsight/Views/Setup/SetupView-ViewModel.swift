//
//  SetupView-ViewModel.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import Foundation
import Supabase
import SwiftUI

extension SetupView {
    @Observable
    class ViewModel {
        static let shared = ViewModel()
        
        let languageLabels: [String: String] = [
            "en": "English",
            "hi": "Hindi",
            "kn": "Kannada"
        ]
        
        var stage: SetupStage = .signIn
        var transitionStage: SetupStage = .signIn
        
        var processingInvite: Bool = false
        
        // MARK: Computed properties
        var headerIcon: String? {
            switch transitionStage {
            case .guardian:
                return "shield.lefthalf.fill"
            case .location:
                return "mappin.and.ellipse"
            case .qrCode:
                return "qrcode.viewfinder"
            default:
                return nil
            }
        }
        
        var headerTitle: String {
            switch transitionStage {
            case .guardian:
                return "Set up as a Guardian"
            case .location:
                return "Location services"
            case .qrCode:
                return "Scan this with Navsight on your device"
            case .complete:
                return "Setup complete"
            default:
                return ""
            }
        }
        
        var headerSubtitle: String {
            switch transitionStage {
            case .guardian:
                return "If you’ve already set up your ward’s device, this is the place to be."
            case .location:
                return "Navsight needs location access to work correctly."
            case .qrCode:
                return "This will set up your side as a guardian."
            case .complete:
                return "You can now hand this back to your ward."
            default:
                return ""
            }
        }
        
        var circleScale: Double {
            switch transitionStage {
            case .guardian:
                return 0.3
            case .location:
                return 1.8
            case .qrCode:
                return 1.8
            case .scan:
                return 1.8
            default:
                return 1.0
            }
        }
        
        // MARK: UI Functions
        func navigate(to stage: SetupStage, transition: Bool = false) {
            if transition {
                withAnimation(.default) {
                    self.transitionStage = stage
                    self.stage = .transition
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(800)), execute: {
                    withAnimation(.default) {
                        self.stage = stage
                    }
                })
                return
            }
            
            withAnimation(.default) {
                self.transitionStage = stage
                self.stage = stage
            }
        }
        
        // MARK: Logical Functions
        func signIn(as role: UserAccount.AccountRole) {
            Task {
                do {
                    try await SignInService.signIn(as: role)
                    
                    if role == .ward {
                        self.navigate(to: .location, transition: true)
                        UserDefaults.standard.set("ward", forKey: "role")
                    } else {
                        self.navigate(to: .scan, transition: true)
                        UserDefaults.standard.set("guardian", forKey: "role")
                    }
                } catch {
                    print("Failed to sign in: \(error.localizedDescription)")
                }
            }
        }
        
        func requestLocationAccess() {
            Task {
                let permission = await LocationStreamingService().requestPermission()
                print("Permission granted: \(permission)")
                
                if permission {
                    navigate(to: .qrCode)
                }
            }
        }
        
        func listenToInviteStatus(id: UUID) async {
            do {
                let channel = Supabase.client.channel("invite-\(id.uuidString)")
                
                let changes =  channel.postgresChange(UpdateAction.self, schema: "public", table: "invites", filter: .eq("id", value: id))
                
                await channel.subscribe()
                
                for await change in changes {
                    let invite: GuardianInvite = try change.record.decode()
                    
                    if invite.accepted {
                        await channel.unsubscribe()
                        
                        try await InviteService.updateSelfWithGuardianID()
                        self.navigate(to: .complete, transition: false)
                    }
                }
            } catch {
                print("Failed to listen to invite: \(error.localizedDescription)")
            }
        }
        
        func processInvite(_ result: String) {
            self.processingInvite = true
            
            Task {
                do {
                    guard let inviteID = UUID(uuidString: result) else { throw "Invite was not a valid UUID" }
                    
                    try await InviteService.accept(id: inviteID)
                    self.navigate(to: .complete, transition: false)
                } catch {
                    print("Failed to process invite: \(error.localizedDescription)")
                }
            }
        }
    }
    
    enum SetupStage {
        case signIn, guardian, location, scan, qrCode, complete, transition
    }
}
