//
//  SetupView-ViewModel.swift
//  Navsight
//
//  Created by Aneesh on 13/5/25.
//

import Foundation

extension SetupView {
    @Observable
    class ViewModel {
        let languageLabels: [String: String] = [
            "en": "English",
            "hi": "Hindi",
            "kn": "Kannada"
        ]
        
        var stage: SetupStage = .signIn
        
        // MARK: Computed properties
        var headerIcon: String {
            switch stage {
            case .location:
                return "mappin.and.ellipse"
            case .qrShow:
                return "qrcode.viewfinder"
            default:
                return ""
            }
        }
        
        var headerTitle: String {
            switch stage {
            case .location:
                return "Location services"
            case .qrShow:
                return "Scan this with Navsight on your device"
            case .complete:
                return "Setup complete"
            default:
                return ""
            }
        }
        
        var headerSubtitle: String {
            switch stage {
            case .location:
                return "Navsight needs location access to work correctly."
            case .qrShow:
                return "This will set up your side as a guardian."
            case .complete:
                return "You can now hand this back to your ward."
            default:
                return ""
            }
        }
        
        var circleScale: Double {
            switch stage {
            case .location:
                return 1.8
            case .qrShow:
                return 2.0
            default:
                return 1.0
            }
        }
        
        // MARK: UI Functions
        func navigate(to stage: SetupStage) {
            self.stage = .transition
            
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: {
                self.stage = stage
            })
        }
    }
    
    enum SetupStage {
        case signIn, guardianSetup, location, qrShow, complete, transition
    }
}
