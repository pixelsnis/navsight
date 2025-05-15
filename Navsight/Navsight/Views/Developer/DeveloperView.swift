//
//  DeveloperView.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import SwiftUI

struct DeveloperView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Views") {
                    NavigationLink("Ward View", value: "ward")
                    NavigationLink("Guardian View", value: "guardian")
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
    }
}

#Preview {
    DeveloperView()
}
