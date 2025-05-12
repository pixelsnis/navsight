//
//  TTSProcessor.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation

enum TTSProcessor {
    static func processAndSave(text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/tts")!
            
            var request = URLRequest(url: endpoint)
            try request.authenticate()
            
            request.httpBody = text.data(using: .utf8)
            
            Task {
                // The API streams back the bytes of audio as a response.
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { throw "Response was not a valid HTTPURLResponse" }
                
                if httpResponse.statusCode != 200 {
                    let error = String(data: data, encoding: .utf8)
                    throw error ?? "Unknown error"
                }
                
                completion(.success(data))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
