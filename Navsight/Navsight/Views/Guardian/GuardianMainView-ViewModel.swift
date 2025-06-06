//
//  GuardianMainView-ViewModel.swift
//  Navsight
//
//  Created by Aneesh on 16/5/25.
//

import Foundation

extension GuardianMainView {
    @Observable
    class ViewModel {
        var latitude: Double = 0
        var longitude: Double = 0
        var updated: Date? = nil
        var live: Bool = false
        
        var ward: UserAccount? = nil
       
        @MainActor
        func observeWardLocation() async throws {
            let lastLatitude = UserDefaults.standard.double(forKey: "last_latitude")
            let lastLongitude = UserDefaults.standard.double(forKey: "last_longitude")

            self.latitude = lastLatitude
            self.longitude = lastLongitude
            
            if let ward = try? await WardInfo.get() {
                try await LocationListener.listen(for: ward) { location in
                    print("Got location")
                    
                    if !self.live {
                        self.live = true
                    }
                    
                    self.latitude = location.latitude
                    self.longitude = location.longitude
                    self.updated = location.updated
                }
            }
        }
    }
}
