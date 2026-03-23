import Foundation

/// Rooli harjoituksen aikana — matches the backend enum values
enum SessionRole: String, Codable, CaseIterable, Identifiable {
    case ampuja = "Ampuja"
    case valmentaja = "Valmentaja"
    case rataAmmunnanJohtaja = "Rata-ammunnan johtaja"
    case tuomari = "Tuomari"
    case radanrakentaja = "Radanrakentaja"
    case muuRooli = "Muu rooli"

    var id: String { rawValue }
}
