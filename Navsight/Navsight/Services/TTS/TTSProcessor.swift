//
//  TTSProcessor.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation

enum TTSProcessor {
    struct TTSRequest: Codable {
        enum SpeechProvider: String, Codable {
            case OpenAI = "openai", ElevenLabs = "elevenlabs"
        }
        
        var text: String
        var language: String
        var provider: SpeechProvider
    }
    
    static func process(text: String, completion: @escaping (Result<AudioCue, Error>) -> Void) {
        do {
            let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/tts")!
            
            var request = URLRequest(url: endpoint)
            try request.authenticate()
            
            request.httpBody = try JSONEncoder().encode(TTSRequest(text: text, language: UserDefaults.standard.string(forKey: "language") ?? "en", provider: .OpenAI))
            
            Task {
                // The API streams back the bytes of audio as a response.
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { throw "Response was not a valid HTTPURLResponse" }
                
                if httpResponse.statusCode != 200 {
                    let error = String(data: data, encoding: .utf8)
                    throw error ?? "Unknown error"
                }
                
                let cue: AudioCue = .init(default: .init(data: data, transcription: [
                    .init(text: text, time: 0)
                ]))
                
                completion(.success(cue))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
