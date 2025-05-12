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

    private let locationManager = CLLocationManager()

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

        // Start listening to the user's location
        locationManager.startUpdatingLocation()
    }

    private func requestPermission() async -> Bool {
        locationManager.requestAlwaysAuthorization()

        return (locationManager.authorizationStatus != .authorizedAlways)
    }
}

extension LocationStreamingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        self.latitude = Double(lat)
        self.longitude = Double(lng)
        
        Task {
            try? await LocationWriter.write(latitude: lat, longitude: lng)
        }
    }
}
