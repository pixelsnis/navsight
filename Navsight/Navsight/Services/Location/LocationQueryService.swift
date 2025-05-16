//
//  LocationQueryService.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import Foundation

// Enum for managing location query services
enum LocationQueryService {
    // Function to query the location service with latitude and longitude
    static func ask(lat: Double, lng: Double) async throws -> AudioCue {
        // Construct the URL for the location service API
        let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/location")!

        // Initialize a URLRequest with the constructed endpoint
        var request = URLRequest(url: endpoint)
        // Attempt to authenticate the request
        try request.authenticate()

        // Set the request method to POST and encode the request body with the provided latitude, longitude, and language
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(
            RequestBody(
                lat: lat, lng: lng,
                language: UserDefaults.standard.string(forKey: "language") ?? "en"))

        // Set a timeout interval for the request
        request.timeoutInterval = 10

        // Send the request and await the response
        let (data, response) = try await URLSession.shared.data(for: request)
        // Ensure the response is a valid HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Response was not a valid HTTPURLResponse"
        }

        // Log the successful receipt of a response
        print("Got response from query")

        // Check if the response status code indicates success
        if httpResponse.statusCode != 200 {
            // If not successful, attempt to decode the error message from the response data
            let error = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw error
        }

        // Extract the transcription from the response headers
        guard let transcription: String = httpResponse.value(forHTTPHeaderField: "X-Transcription")
        else { throw "Transcription was not returned by API" }
        // Log the transcription and size of the audio file received
        print(
            "API responded with audio file of size \(data.count) bytes and transcription: \(transcription)"
        )

        // Construct a Dialogue object from the received data and transcription
        let dialogue = Dialogue(
            data: data,
            transcription: [
                .init(text: transcription, time: 0)
            ])

        // Return an AudioCue object initialized with the constructed dialogue
        return .init(default: dialogue)
    }

    // Struct to represent the request body for the location query
    struct RequestBody: Codable {
        var lat: Double
        var lng: Double
        var language: String
    }
}
