import Foundation
import SwiftData

@Model
final class Weapon {
    var name: String
    var type: WeaponType
    var caliber: String?
    var erva: Bool
    var purchaseDate: Date?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Session.weapon)
    var sessions: [Session] = []

    init(
        name: String,
        type: WeaponType,
        caliber: String? = nil,
        erva: Bool = false,
        purchaseDate: Date? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.type = type
        self.caliber = caliber
        self.erva = erva
        self.purchaseDate = purchaseDate
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
    }
}
