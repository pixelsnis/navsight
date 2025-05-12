//
//  AuthenticateRequest.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation

extension URLRequest {
    mutating func authenticate() throws {
        guard let token = Supabase.client.auth.currentSession?.accessToken else { throw "User not authenticated" }
        
        self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
