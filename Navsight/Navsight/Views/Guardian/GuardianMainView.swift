//
//  GuardianMainView.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import MapKit
import SwiftUI

struct GuardianMainView: View {
    static private let viewDelta = 0.01
    
    @State private var vm = ViewModel()
    
    @State private var mapCameraPosition = MapCameraPosition.region(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: viewDelta, longitudeDelta: viewDelta)))
    
    @State private var preferUserInteractionForCameraPosition: Bool = false
    @State private var resetCameraPreferenceWorkItem: DispatchWorkItem? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $mapCameraPosition, content: {
                Annotation(vm.ward?.name.split(separator: " ").first ?? "Location", coordinate: .init(latitude: vm.latitude, longitude: vm.longitude)) {
                    LocationBlinker(live: vm.live)
                }
            })
            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged({ _ in
                setUserPreferredCameraPosition(true)
            }))
            
            HStack(spacing: 8) {
                if vm.live {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green, radius: 2)
                        .transition(.blurReplace())
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .transition(.blurReplace())
                }
                
                Text(vm.live ? "Live" : "Updating...")
                    .contentTransition(.numericText())
            }
            .animation(.default, value: vm.live)
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background {
                Capsule()
                    .fill(.white)
                    .shadow(radius: 8, x: 0, y: 4)
            }
            .padding(.vertical, 48)
            .colorScheme(.light)
        }
        .onAppear {
            updateCameraPosition()
            
            Task {
                do {
                    try await vm.observeWardLocation()
                } catch {
                    print("Failed to observe location: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: vm.latitude) {
            updateCameraPosition()
        }
        .onChange(of: vm.longitude) {
            updateCameraPosition()
        }
        .ignoresSafeArea()
    }
    
    private func updateCameraPosition() {
        if preferUserInteractionForCameraPosition { return }
        
        withAnimation(.default) {
            mapCameraPosition = .region(.init(center: .init(latitude: vm.latitude, longitude: vm.longitude), span: .init(latitudeDelta: GuardianMainView.viewDelta, longitudeDelta: GuardianMainView.viewDelta)))
        }
    }
    
    private func setUserPreferredCameraPosition(_ value: Bool) {
        preferUserInteractionForCameraPosition = value
        
        if preferUserInteractionForCameraPosition {
            resetCameraPreferenceWorkItem?.cancel()
            resetCameraPreferenceWorkItem = .init(block: {
                setUserPreferredCameraPosition(false)
            })
            
            if let resetCameraPreferenceWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(3)), execute: resetCameraPreferenceWorkItem)
            }
            
            return
        }
    }
}

#Preview {
    GuardianMainView()
}
