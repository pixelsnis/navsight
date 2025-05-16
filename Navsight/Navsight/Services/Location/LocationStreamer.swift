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

        // Set the CLLocationManager delegate to self to handle location updates and authorization changes
        locationManager.delegate = self
    }

    func observe() async {
        // Check if location permission is granted
        let permissionGranted = locationManager.authorizationStatus

        // The app needs location to always be granted for it to work correctly.
        switch permissionGranted {
        case .authorizedAlways:
            // If permission is already granted, proceed to start location updates
            break
        case .notDetermined:
            // If permission is not determined, request permission and handle the response
            let request = await requestPermission()
            if !request {
                // If permission is denied, update the service status and error
                status = .errored
                error = .permissionDenied
                return
            }
            break
        default:
            // If permission is denied or restricted, update the service status and error
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
        // Request a single location update
        locationManager.requestLocation()
    }

    func requestPermission() async -> Bool {
        let currentAuthorization = locationManager.authorizationStatus
        if currentAuthorization != .notDetermined {
            // If the current authorization status is not "not determined", check if permission is already granted
            return currentAuthorization == .authorizedAlways
                || currentAuthorization == .authorizedWhenInUse
        }

        // If the current authorization status is "not determined", request permission and handle the response
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

        // Check if the location has changed before updating
        if self.latitude == lat && self.longitude == lng { return }  // Ignore writing if the location hasn't changed

        self.latitude = Double(lat)
        self.longitude = Double(lng)

        // Asynchronously write the updated location to Supabase
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

        // Handle authorization status changes
        if manager.authorizationStatus == .authorizedAlways
            || manager.authorizationStatus == .authorizedWhenInUse
        {
            // If permission is granted, resume the continuation with true
            continuation.resume(returning: true)
        } else if manager.authorizationStatus == .denied
            || manager.authorizationStatus == .restricted
        {
            // If permission is denied or restricted, resume the continuation with false
            continuation.resume(returning: false)
        }

        // Clear the continuation after handling the authorization status change
        self.continuation = nil
    }
}
