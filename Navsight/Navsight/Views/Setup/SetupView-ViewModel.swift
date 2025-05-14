//
//  SetupView-ViewModel.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import AuthenticationServices
import Foundation
import SwiftUI

extension SetupView {
    @Observable
    class ViewModel {
        let languageLabels: [String: String] = [
            "en": "English",
            "hi": "Hindi",
            "kn": "Kannada"
        ]
        
        var stage: SetupStage = .signIn
        var transitionStage: SetupStage = .signIn
        
        // MARK: Computed properties
        var headerIcon: String {
            switch transitionStage {
            case .location:
                return "mappin.and.ellipse"
            case .qrCode:
                return "qrcode.viewfinder"
            default:
                return ""
            }
        }
        
        var headerTitle: String {
            switch transitionStage {
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
            case .location:
                return 1.8
            case .qrCode:
                return 2.0
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
        func signIn(_ result: Result<ASAuthorization, any Error>, as role: UserAccount.AccountRole) {
            Task {
                do {
                    try await SignInService.signIn(result, as: role)
                    self.navigate(to: .location, transition: true)
                } catch {
                    print("Failed to sign in: \(error.localizedDescription)")
                }
            }
        }
        
        func requestLocationAccess() {
            Task {
                let permission = await LocationStreamingService().requestPermission()
                
                if permission {
                    navigate(to: .qrCode)
                }
            }
        }
    }
    
    enum SetupStage {
        case signIn, location, qrCode, complete, transition
    }
}
