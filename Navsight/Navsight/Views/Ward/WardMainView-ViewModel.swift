//
//  WardMainView-ViewModel.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import Foundation

extension WardMainView {
    @Observable
    class ViewModel {
        var status: String = "Press and hold anywhere to start"
        var querying: Bool = false
        
        var successVibrations: Int = 0
        
        private(set) var locationStreamer: LocationStreamingService = .init()
        
        func startLocationService() async {
            await locationStreamer.observe()
        }
        
        func queryLocation(onResult: @escaping (AudioCue) -> Void) async {
            if querying { return }
            
            guard let latitude = locationStreamer.latitude, let longitude = locationStreamer.longitude else { return }
            
            querying = true
            status = "Looking up your location"
            
            Task {
                do {
                    let cue = try await LocationQueryService.ask(lat: latitude, lng: longitude)
                    
                    status = "Speaking now"
                    onResult(cue)
                    
                    successVibrations += 1
                    
                    querying = false
                } catch {
                    print("Failed to query location: \(error.localizedDescription)")
                    querying = false
                }
            }
        }
    }
}
