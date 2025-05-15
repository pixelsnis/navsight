import Foundation

struct Location: Codable {
    var userID: UUID
    var latitude: Double
    var longitude: Double
    var updated: Date
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id", latitude, longitude, updated
    }
}
