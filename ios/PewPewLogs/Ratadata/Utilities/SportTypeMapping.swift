import Foundation

/// Maps weapon types to their available sport types.
/// Ported from the Vue.js frontend's `allSportTypes` object.
enum SportTypeMapping {
    static let mapping: [WeaponType: [String]] = [
        .pistooli: [
            "25m isopistooli", "Action Shooting", "Cowboy Action Shooting",
            "Falling plates", "IDPA", "IPSC", "Kohdistus", "Metsästys",
            "Muu harjoittelu", "Perinnepistooli 25m koulu",
            "Perinnepistooli 25m kuvio", "Perinnepistooli 50m",
            "Practical", "Precision Pistol", "Reserviläisammunta 3",
            "Reserviläisammunta 4", "Siluettiammunta",
            "Sovellettu perinneammunta", "SRA"
        ],
        .kivaari: [
            "100m hirviammunta", "300m kivääri 3x20", "300m kivääri 3x40",
            "300m kivääri makuu", "300m vakiokivääri 3x20",
            "Cowboy Action Shooting", "Metsästys", "Falling plates",
            "Hirvenhiihto", "IDPA", "IPSC", "SRA", "Kaksoishirvi",
            "Kasa-ammunta", "Kenttäammunta", "Kohdistus", "Muu laji",
            "Perinnekivääri 100m", "Perinnekivääri 150m",
            "Perinnekivääri 300m", "RA 7", "Precision Rifle Series",
            "Reserviläisammunta 1", "Reserviläisammunta 2", "Tarkka-ammunta"
        ],
        .haulikko: [
            "Skeet", "Trap", "Kaksoistrap", "Practical Shotgun",
            "Sporting Clays", "Muu"
        ],
        .pcc: ["IPSC PCC", "SRA", "Muu"],
        .revolveri: [
            "Precision Pistol", "Action Shooting", "Falling plates",
            "IDPA", "IPSC", "Kohdistus", "Metsästys",
            "Perinnepistooli 25m koulu", "Perinnepistooli 25m kuvio",
            "Perinnepistooli 50m", "Muu harjoittelu"
        ],
        .ilmaAse: ["Muu"],
        .deaktivoitu: ["Muu"],
        .yhdistelmaase: ["Muu"],
        .merkinantoase: ["Muu"],
        .kaasuase: ["Muu"],
        .muu: ["Muu"]
    ]

    /// Returns available sport types for a given weapon type.
    static func sportTypes(for weaponType: WeaponType) -> [String] {
        mapping[weaponType] ?? ["Muu"]
    }
}
