import Foundation

enum LocationWriter {
    static func write(latitude: Double, longitude: Double) async throws {
        guard let userID = UserID.current else { throw "User not authenticated" }
        
        let location: Location = .init(userID: userID, latitude: latitude, longitude: longitude, updated: .now)
        
        print("Writing location...")
        try await Supabase.client.from("location").upsert(location).eq("user_id", value: userID).execute()
        print("Location written.")
    }
}
