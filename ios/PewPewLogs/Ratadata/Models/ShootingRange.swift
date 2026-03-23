import Foundation
import SwiftData

@Model
final class ShootingRange {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var notes: String?
    var website: String?
    var phoneNumber: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Session.range)
    var sessions: [Session] = []

    init(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        notes: String? = nil,
        website: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.website = website
        self.phoneNumber = phoneNumber
        self.createdAt = .now
        self.updatedAt = .now
    }
}
