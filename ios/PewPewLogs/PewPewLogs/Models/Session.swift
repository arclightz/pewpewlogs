import Foundation
import SwiftData

@Model
final class Session {
    // MARK: - Mandatory fields
    var date: Date
    var numberOfShotsFired: Int
    var type: SessionType
    var sportType: String
    var role: SessionRole

    // MARK: - Optional fields
    var weather: String?
    var result: String?
    var hitFactor: Double?
    var compScore: Double?
    var distanceToTarget: Double?
    var notes: String?
    var signature: Data?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Photo storage (file names on disk)
    var photoFileNames: [String] = []

    // MARK: - Relationships
    var weapon: Weapon?
    var range: ShootingRange?

    init(
        date: Date,
        numberOfShotsFired: Int,
        type: SessionType,
        sportType: String,
        role: SessionRole = .ampuja,
        weather: String? = nil,
        result: String? = nil,
        hitFactor: Double? = nil,
        compScore: Double? = nil,
        distanceToTarget: Double? = nil,
        notes: String? = nil,
        signature: Data? = nil,
        weapon: Weapon? = nil,
        range: ShootingRange? = nil
    ) {
        self.date = date
        self.numberOfShotsFired = numberOfShotsFired
        self.type = type
        self.sportType = sportType
        self.role = role
        self.weather = weather
        self.result = result
        self.hitFactor = hitFactor
        self.compScore = compScore
        self.distanceToTarget = distanceToTarget
        self.notes = notes
        self.signature = signature
        self.weapon = weapon
        self.range = range
        self.createdAt = .now
        self.updatedAt = .now
    }
}
