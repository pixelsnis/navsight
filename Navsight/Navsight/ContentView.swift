//
//  ContentView.swift
//  Navsight
//
//  Created by Aneesh on 10/5/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("signedIn") private var signedIn: Bool = false
    
    var body: some View {
        if signedIn {
            
        } else {
            SetupView()
        }
    }
}

#Preview {
    ContentView()
}
