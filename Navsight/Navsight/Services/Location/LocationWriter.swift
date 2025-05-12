import Foundation

enum LocationWriter {
    static func write(latitude: Double, longitude: Double) async throws {
        guard let userID = Supabase.client.auth.currentUser?.id else { throw "User not authenticated" }
        
        let location: Location = .init(userID: userID, latitude: latitude, longitude: longitude, updated: .now)
        
        try await Supabase.client.from("location").upsert(location).eq("user_id", value: userID).execute()
    }
}
