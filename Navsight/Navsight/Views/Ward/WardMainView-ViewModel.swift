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
        
        private(set) var locationStreamer: LocationStreamingService = .init()
        
        func startLocationService() async {
            await locationStreamer.observe()
        }
        
        func queryLocation(onResult: @escaping (AudioCue) -> Void) async {
            
        }
    }
}
