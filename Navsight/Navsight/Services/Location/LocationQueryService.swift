//
//  LocationQueryService.swift
//  Navsight
//
//  Created by Aneesh on 15/5/25.
//

import Foundation

enum LocationQueryService {
    static func ask(lat: Double, lng: Double) async throws -> AudioCue {
        let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/location")!
        
        var request = URLRequest(url: endpoint)
        try request.authenticate()
        
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(RequestBody(lat: lat, lng: lng, language: UserDefaults.standard.string(forKey: "language") ?? "en"))
        
        request.timeoutInterval = 10
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw "Response was not a valid HTTPURLResponse" }
        
        print("Got response from query")
        
        if httpResponse.statusCode != 200 {
            let error = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw error
        }
        
        guard let transcription: String = httpResponse.value(forHTTPHeaderField: "X-Transcription") else { throw "Transcription was not returned by API" }
        print("API responded with audio file of size \(data.count) bytes and transcription: \(transcription)")
        
        let dialogue = Dialogue(data: data, transcription: [
            .init(text: transcription, time: 0)
        ])
        
        return .init(default: dialogue)
    }
    
    struct RequestBody: Codable {
        var lat: Double
        var lng: Double
        var language: String
    }
}
