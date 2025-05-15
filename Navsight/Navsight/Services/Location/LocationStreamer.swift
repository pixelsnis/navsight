//
//  LocationStreamer.swift
//  Navsight
//
//  Created by Aneesh on 10/5/25.
//

import CoreLocation
import Foundation

@Observable
class LocationStreamingService: NSObject {
    enum Status {
        case inactive, streaming, errored
    }

    enum LocationServiceError {
        case permissionDenied, unknown
    }

    var latitude: Double?
    var longitude: Double?
    var updated: Date = .distantPast
    var status: Status = .inactive
    var error: LocationServiceError? = nil

    private let locationManager: CLLocationManager = .init()
    private var continuation: CheckedContinuation<Bool, Never>? = nil
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }

    func observe() async {
        // Check if location permission is granted
        let permissionGranted = locationManager.authorizationStatus

        // The app needs location to always be granted for it to work correctly.
        switch permissionGranted {
        case .authorizedAlways:
            break
        case .notDetermined:
            let request = await requestPermission()
            if !request {
                status = .errored
                error = .permissionDenied
                return
            }
            break
        default:
            status = .errored
            error = .permissionDenied
            return
        }
        
        print("Location service ready to start")
        
        // Start listening to the user's location
        locationManager.startUpdatingLocation()
        print("Listening to user location")
    }
    
    func update() {
        locationManager.requestLocation()
    }

    func requestPermission() async -> Bool {
        let currentAuthorization = locationManager.authorizationStatus
        if (currentAuthorization != .notDetermined) {
            return currentAuthorization == .authorizedAlways || currentAuthorization == .authorizedWhenInUse
        }
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.requestAlwaysAuthorization()
        }
    }
}

extension LocationStreamingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        if (self.latitude == lat && self.longitude == lng) { return } // Ignore writing if the location hasn't changed

        self.latitude = Double(lat)
        self.longitude = Double(lng)
        
        Task {
            do {
                try await LocationWriter.write(latitude: lat, longitude: lng)
            } catch {
                print("Failed to write to Supabase: \(error.localizedDescription)")
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation else { return }
        
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            continuation.resume(returning: true)
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            continuation.resume(returning: false)
        }
        
        self.continuation = nil
    }
}

