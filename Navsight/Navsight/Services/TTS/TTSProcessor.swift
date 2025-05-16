//
//  TTSProcessor.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation

// Enum for processing TTS requests
enum TTSProcessor {
    // Struct to represent a TTS request
    struct TTSRequest: Codable {
        // Enum for specifying the speech provider
        enum SpeechProvider: String, Codable {
            case OpenAI = "openai", ElevenLabs = "elevenlabs"
        }

        // Properties of the TTS request
        var text: String
        var language: String
        var provider: SpeechProvider
    }

    // Function to process a TTS request
    static func process(text: String, completion: @escaping (Result<AudioCue, Error>) -> Void) {
        do {
            // Construct the URL for the TTS API endpoint
            let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/tts")!

            // Create a URLRequest for the endpoint
            var request = URLRequest(url: endpoint)
            // Attempt to authenticate the request
            try request.authenticate()

            // Encode the TTS request into JSON and set it as the request body
            request.httpBody = try JSONEncoder().encode(
                TTSRequest(
                    text: text, language: UserDefaults.standard.string(forKey: "language") ?? "en",
                    provider: .OpenAI))

            // Use Task to asynchronously process the request
            Task {
                // Attempt to send the request and get the response data
                let (data, response) = try await URLSession.shared.data(for: request)
                // Ensure the response is a valid HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw "Response was not a valid HTTPURLResponse"
                }

                // Check if the response status code indicates success
                if httpResponse.statusCode != 200 {
                    // If not successful, attempt to decode the error message from the response data
                    let error = String(data: data, encoding: .utf8)
                    throw error ?? "Unknown error"
                }

                // If successful, create an AudioCue from the response data and the original text
                let cue: AudioCue = .init(
                    default: .init(
                        data: data,
                        transcription: [
                            .init(text: text, time: 0)
                        ]))

                // Call the completion handler with the successful result
                completion(.success(cue))
            }
        } catch {
            // If any error occurs during processing, call the completion handler with the error
            completion(.failure(error))
        }
    }
}
