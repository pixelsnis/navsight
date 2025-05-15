//
//  NavsightApp.swift
//  Navsight
//
//  Created by Aneesh on 10/5/25.
//

import SwiftUI

@main
struct NavsightApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            "language": "en",
            "signedIn": false,
            "intro_finished": false
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
