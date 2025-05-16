//
//  LocationListener.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation
import Supabase

enum LocationListener {
    static func listen(for user: UserAccount, onChange: @escaping (Location) -> Void) async throws {
        let userID = user.id
        
        // Get initial location data
        let locationQueryResult: [Location] = try await Supabase.client.from("location").select().eq("user_id", value: userID).execute().value
        if let location = locationQueryResult.first {
            onChange(location)
        }
        
        let channel =  Supabase.client.channel("location-\(userID.uuidString)")
        
        let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "location", filter: .eq("user_id", value: userID))
        await channel.subscribe()
        
        print("Listening for location updates")
        
        for await change in changes {
            switch change {
            case .update(let update):
                let location = try update.decodeRecord(as: Location.self, decoder: JSONDecoder())
                onChange(location)
            case .insert(let insert):
                let location = try insert.decodeRecord(as: Location.self, decoder: JSONDecoder())
                onChange(location)
            default:
                break
            }
        }
    }
}
