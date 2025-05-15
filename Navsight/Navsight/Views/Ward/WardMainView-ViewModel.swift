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
        var status: String = ""
        var querying: Bool = false
        
        private(set) var locationStreamer: LocationStreamingService = .init()
        
        func startLocationService() async {
            await locationStreamer.observe()
        }
        
        func queryLocation(onResult: @escaping (AudioCue) -> Void) async {
            if querying { return }
            
            guard let latitude = locationStreamer.latitude, let longitude = locationStreamer.longitude else { return }
            
            querying = true
            
            Task {
                do {
                    let cue = try await LocationQueryService.ask(lat: latitude, lng: longitude)
                    onResult(cue)
                    
                    querying = false
                } catch {
                    print("Failed to query location: \(error.localizedDescription)")
                    querying = false
                }
            }
        }
    }
}
