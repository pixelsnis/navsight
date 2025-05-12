import Foundation

struct Location: Codable {
    var userID: UUID
    var latitude: Double
    var longitude: Double
    var updated: Date
}
