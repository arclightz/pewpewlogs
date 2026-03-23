import Foundation
import SwiftData

/// Provides a pre-populated ModelContainer for SwiftUI previews.
@MainActor
enum PreviewSampleData {
    static let container: ModelContainer = {
        let schema = Schema([
            Weapon.self,
            ShootingRange.self,
            Instructor.self,
            Session.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let cal = Calendar.current

        // MARK: - Weapons

        let glock17 = Weapon(
            name: "Glock 17 Gen5",
            type: .pistooli,
            caliber: "9x19mm",
            erva: false,
            purchaseDate: cal.date(from: DateComponents(year: 2023, month: 3, day: 15)),
            notes: "Kilpailukäyttöön"
        )
        let cz75 = Weapon(
            name: "CZ 75 SP-01 Shadow",
            type: .pistooli,
            caliber: "9x19mm",
            erva: false,
            purchaseDate: cal.date(from: DateComponents(year: 2024, month: 1, day: 10)),
            notes: "IPSC Production"
        )
        let cz457 = Weapon(
            name: "CZ 457 Varmint",
            type: .kivaari,
            caliber: ".22 LR",
            erva: false,
            purchaseDate: cal.date(from: DateComponents(year: 2022, month: 8, day: 1))
        )
        let tikkaT3x = Weapon(
            name: "Tikka T3x TAC A1",
            type: .kivaari,
            caliber: ".308 Win",
            erva: false,
            purchaseDate: cal.date(from: DateComponents(year: 2024, month: 6, day: 20)),
            notes: "Tarkka-ammunta"
        )
        let beretta686 = Weapon(
            name: "Beretta 686 Silver Pigeon",
            type: .haulikko,
            caliber: "12/76",
            erva: false,
            notes: "Skeet-ase"
        )
        let swMp15 = Weapon(
            name: "S&W M&P15-22",
            type: .pcc,
            caliber: ".22 LR",
            erva: false,
            purchaseDate: cal.date(from: DateComponents(year: 2025, month: 2, day: 5))
        )
        [glock17, cz75, cz457, tikkaT3x, beretta686, swMp15].forEach { context.insert($0) }

        // MARK: - Ranges

        let helsinkiRange = ShootingRange(
            name: "Helsingin Ampumarata",
            address: "Ampumaradantie 1, 00300 Helsinki",
            latitude: 60.1867,
            longitude: 24.9557,
            website: "https://www.ha.fi",
            phoneNumber: "+358 9 123 4567"
        )
        let jyvaskylaRange = ShootingRange(
            name: "Keski-Suomen Ampujat ry",
            address: "Ratakatu 10, 40100 Jyväskylä",
            latitude: 62.2426,
            longitude: 25.7473,
            notes: "Ulkorata, avoinna ma-su"
        )
        let tampereenAmpumarata = ShootingRange(
            name: "Tampereen Ampumarata",
            address: "Hervannantie 100, 33720 Tampere",
            latitude: 61.4501,
            longitude: 23.8502,
            website: "https://www.tampere-ampumarata.fi"
        )
        [helsinkiRange, jyvaskylaRange, tampereenAmpumarata].forEach { context.insert($0) }

        // MARK: - Instructors

        let instructorNiemi = Instructor(name: "Mikko Niemi")
        let instructorVirtanen = Instructor(name: "Laura Virtanen")
        let instructorKorhonen = Instructor(name: "Jari Korhonen")
        [instructorNiemi, instructorVirtanen, instructorKorhonen].forEach { context.insert($0) }

        // MARK: - Sessions (spanning ~4 months for good chart coverage)

        func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
            cal.date(from: DateComponents(year: year, month: month, day: day))!
        }

        let sessions: [Session] = [
            // December 2025
            Session(
                date: date(2025, 12, 3),
                numberOfShotsFired: 200,
                type: .harjoitus,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Pakkanen, -8°C",
                hitFactor: 4.12,
                notes: "Ensimmäinen talviharjoitus",
                instructorName: instructorNiemi.name,
                weapon: glock17,
                range: helsinkiRange,
                instructor: instructorNiemi
            ),
            Session(
                date: date(2025, 12, 10),
                numberOfShotsFired: 75,
                type: .kilpailu,
                sportType: "Skeet",
                role: .ampuja,
                weather: "Lumisade, -3°C",
                result: "21/25",
                distanceToTarget: 25,
                weapon: beretta686,
                range: jyvaskylaRange
            ),
            Session(
                date: date(2025, 12, 18),
                numberOfShotsFired: 0,
                type: .kuivaharjoittelu,
                sportType: "IPSC",
                role: .ampuja,
                notes: "Vedon harjoittelua kotona",
                weapon: cz75,
                range: helsinkiRange
            ),
            Session(
                date: date(2025, 12, 28),
                numberOfShotsFired: 120,
                type: .harjoitus,
                sportType: "Kohdistus",
                role: .ampuja,
                weather: "Selkeä, -12°C",
                distanceToTarget: 100,
                weapon: cz457,
                range: jyvaskylaRange
            ),

            // January 2026
            Session(
                date: date(2026, 1, 5),
                numberOfShotsFired: 180,
                type: .harjoitus,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Pilvinen, -5°C",
                hitFactor: 4.67,
                notes: "Liikkuvia maaleja, hyvä kehitys",
                instructorName: instructorVirtanen.name,
                weapon: cz75,
                range: helsinkiRange,
                instructor: instructorVirtanen
            ),
            Session(
                date: date(2026, 1, 12),
                numberOfShotsFired: 50,
                type: .valmennus,
                sportType: "Tarkka-ammunta",
                role: .ampuja,
                weather: "Tuulinen, -2°C",
                distanceToTarget: 300,
                notes: "Tuulilukemien harjoittelu Jarin kanssa",
                instructorName: instructorKorhonen.name,
                weapon: tikkaT3x,
                range: tampereenAmpumarata,
                instructor: instructorKorhonen
            ),
            Session(
                date: date(2026, 1, 18),
                numberOfShotsFired: 250,
                type: .kilpailu,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Aurinkoinen, -1°C",
                result: "83.4%",
                hitFactor: 5.89,
                compScore: 83.4,
                instructorName: instructorNiemi.name,
                weapon: glock17,
                range: helsinkiRange,
                instructor: instructorNiemi
            ),
            Session(
                date: date(2026, 1, 25),
                numberOfShotsFired: 100,
                type: .seuranViikkokisa,
                sportType: "Skeet",
                role: .ampuja,
                weather: "Pilvinen, +1°C",
                result: "23/25",
                weapon: beretta686,
                range: jyvaskylaRange
            ),

            // February 2026
            Session(
                date: date(2026, 2, 2),
                numberOfShotsFired: 160,
                type: .harjoitus,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Sade, +3°C",
                hitFactor: 5.11,
                weapon: cz75,
                range: helsinkiRange
            ),
            Session(
                date: date(2026, 2, 8),
                numberOfShotsFired: 80,
                type: .harjoituskilpailu,
                sportType: "Kohdistus",
                role: .ampuja,
                weather: "Selkeä, -4°C",
                result: "92/100",
                distanceToTarget: 50,
                weapon: cz457,
                range: tampereenAmpumarata
            ),
            Session(
                date: date(2026, 2, 15),
                numberOfShotsFired: 300,
                type: .kilpailu,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Aurinkoinen, +2°C",
                result: "91.2%",
                hitFactor: 6.34,
                compScore: 91.2,
                notes: "Kauden paras tulos!",
                instructorName: instructorNiemi.name,
                weapon: cz75,
                range: helsinkiRange,
                instructor: instructorNiemi
            ),
            Session(
                date: date(2026, 2, 16),
                numberOfShotsFired: 0,
                type: .muuMerkinta,
                sportType: "IPSC",
                role: .radanrakentaja,
                notes: "Radan rakennus seuraavan päivän kisaan",
                weapon: glock17,
                range: helsinkiRange
            ),
            Session(
                date: date(2026, 2, 22),
                numberOfShotsFired: 60,
                type: .valmennus,
                sportType: "Tarkka-ammunta",
                role: .ampuja,
                weather: "Lumisade, -6°C",
                distanceToTarget: 300,
                instructorName: instructorKorhonen.name,
                weapon: tikkaT3x,
                range: tampereenAmpumarata,
                instructor: instructorKorhonen
            ),

            // March 2026
            Session(
                date: date(2026, 3, 1),
                numberOfShotsFired: 175,
                type: .harjoitus,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Pilvinen, +5°C",
                hitFactor: 5.56,
                weapon: glock17,
                range: helsinkiRange
            ),
            Session(
                date: date(2026, 3, 8),
                numberOfShotsFired: 100,
                type: .seuranViikkokisa,
                sportType: "Skeet",
                role: .ampuja,
                weather: "Aurinkoinen, +8°C",
                result: "24/25",
                weapon: beretta686,
                range: jyvaskylaRange
            ),
            Session(
                date: date(2026, 3, 10),
                numberOfShotsFired: 150,
                type: .harjoitus,
                sportType: "PCC",
                role: .ampuja,
                weather: "Selkeä, +6°C",
                notes: "Ensimmäinen harjoitus uudella PCC:llä",
                weapon: swMp15,
                range: tampereenAmpumarata
            ),
            Session(
                date: date(2026, 3, 15),
                numberOfShotsFired: 220,
                type: .harjoituskilpailu,
                sportType: "IPSC",
                role: .ampuja,
                weather: "Puolipilvinen, +10°C",
                result: "88.7%",
                hitFactor: 6.01,
                compScore: 88.7,
                instructorName: instructorVirtanen.name,
                weapon: cz75,
                range: helsinkiRange,
                instructor: instructorVirtanen
            ),
            Session(
                date: date(2026, 3, 20),
                numberOfShotsFired: 40,
                type: .valmennus,
                sportType: "Tarkka-ammunta",
                role: .ampuja,
                weather: "Tuulinen, +7°C",
                distanceToTarget: 600,
                notes: "Pitkän matkan harjoitus, tuulikorjaukset",
                instructorName: instructorKorhonen.name,
                weapon: tikkaT3x,
                range: tampereenAmpumarata,
                instructor: instructorKorhonen
            ),
        ]
        sessions.forEach { context.insert($0) }

        return container
    }()
}
