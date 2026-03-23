import Foundation

/// Asetyyppi — matches the backend enum values
enum WeaponType: String, Codable, CaseIterable, Identifiable {
    case pistooli = "Pistooli"
    case kivaari = "Kivääri"
    case haulikko = "Haulikko"
    case revolveri = "Revolveri"
    case pcc = "PCC"
    case ilmaAse = "Ilma-ase"
    case deaktivoitu = "Deaktivoitu ampuma-ase"
    case muu = "Muu"
    case yhdistelmaase = "Yhdistelmäase"
    case merkinantoase = "Merkinantoase"
    case kaasuase = "Kaasuase"

    var id: String { rawValue }
}
