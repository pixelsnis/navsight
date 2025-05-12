//
//  LocationListener.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation
import Supabase

@Observable
class LocationListener {
    private(set) var location: Location? = nil
    private(set) var userID: UUID
    
    init(for userID: UUID) {
        self.userID = userID
    }
    
    func listen() async throws {
        let channel =  Supabase.client.channel("location-\(userID.uuidString)")
        await channel.subscribe()
        
        let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "location", filter: .eq("user_id", value: userID))
        
        for await change in changes {
            switch change {
            case .update(let update):
                try updateEvent(update)
            case .insert(let insert):
                try insertEvent(insert)
            default:
                break
            }
        }
    }
    
    // MARK: Update handles
    private func updateEvent(_ update: UpdateAction) throws {
        self.location = try update.decodeRecord(as: Location.self, decoder: JSONDecoder())
    }
    
    private func insertEvent(_ insert: InsertAction) throws {
        self.location = try insert.decodeRecord(as: Location.self, decoder: JSONDecoder())
    }
}
