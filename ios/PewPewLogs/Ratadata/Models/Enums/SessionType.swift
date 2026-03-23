import Foundation

/// Istunnon tyyppi — matches the backend enum values
enum SessionType: String, Codable, CaseIterable, Identifiable {
    case kilpailu = "Kilpailu"
    case harjoitus = "Harjoitus"
    case harjoituskilpailu = "Harjoituskilpailu"
    case kuivaharjoittelu = "Kuivaharjoittelu"
    case seuranViikkokisa = "Seuran viikkokisa"
    case valmennus = "Valmennus"
    case muuMerkinta = "Muu merkintä"

    var id: String { rawValue }
}
