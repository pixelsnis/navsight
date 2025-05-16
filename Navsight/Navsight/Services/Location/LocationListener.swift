//
//  LocationListener.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation
import Supabase

// Enum for managing location updates
enum LocationListener {
    // Function to start listening for location updates for a given user
    static func listen(for user: UserAccount, onChange: @escaping (Location) -> Void) async throws {
        let userID = user.id

        // Retrieve the user's initial location data
        let locationQueryResult: [Location] = try await Supabase.client.from("location").select()
            .eq("user_id", value: userID).execute().value
        // If there is an initial location, notify the change handler
        if let location = locationQueryResult.first {
            onChange(location)
        }

        // Create a channel to listen for location updates specific to the user
        let channel = Supabase.client.channel("location-\(userID.uuidString)")

        // Define the type of changes to listen for (inserts and updates) and filter by user ID
        let changes = channel.postgresChange(
            AnyAction.self, schema: "public", table: "location",
            filter: .eq("user_id", value: userID))
        // Subscribe to the channel to start receiving updates
        await channel.subscribe()

        print("Listening for location updates")

        // Process incoming changes
        for await change in changes {
            // Handle location updates and inserts
            switch change {
            case .update(let update):
                // Decode the update into a Location object and notify the change handler
                let location = try update.decodeRecord(as: Location.self, decoder: JSONDecoder())
                onChange(location)
            case .insert(let insert):
                // Decode the insert into a Location object and notify the change handler
                let location = try insert.decodeRecord(as: Location.self, decoder: JSONDecoder())
                onChange(location)
            default:
                break
            }
        }
    }
}
