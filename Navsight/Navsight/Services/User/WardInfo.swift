//
//  WardInfo.swift
//  Navsight
//
//  Created by Aneesh on 16/5/25.
//

import Foundation

enum WardInfo {
    static func get() async throws -> UserAccount? {
        guard let userID = UserID.current else { throw "User not authenticated" }
        
        let queryResult: [UserAccount] = try await Supabase.client.from("users").select().eq("guardian", value: userID).execute().value
        guard let wardAccount = queryResult.first else { return nil }
        
        UserDefaults.standard.set(try JSONEncoder().encode(wardAccount), forKey: "ward")
        return wardAccount
    }
}
