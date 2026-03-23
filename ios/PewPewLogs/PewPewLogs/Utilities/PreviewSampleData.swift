import Foundation
import SwiftData

/// Provides a pre-populated ModelContainer for SwiftUI previews.
@MainActor
enum PreviewSampleData {
    static let container: ModelContainer = {
        let schema = Schema([
            Weapon.self,
            ShootingRange.self,
            Session.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        // MARK: - Sample Weapons
        let glock17 = Weapon(
            name: "Glock 17 Gen5",
            type: .pistooli,
            caliber: "9x19mm",
            erva: false,
            purchaseDate: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15)),
            notes: "Kilpailukäyttöön"
        )
        let cz457 = Weapon(
            name: "CZ 457 Varmint",
            type: .kivaari,
            caliber: ".22 LR",
            erva: false,
            purchaseDate: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 1))
        )
        let beretta686 = Weapon(
            name: "Beretta 686 Silver Pigeon",
            type: .haulikko,
            caliber: "12/76",
            erva: false,
            notes: "Skeet-ase"
        )
        [glock17, cz457, beretta686].forEach { context.insert($0) }

        // MARK: - Sample Ranges
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
        [helsinkiRange, jyvaskylaRange].forEach { context.insert($0) }

        // MARK: - Sample Sessions
        let session1 = Session(
            date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
            numberOfShotsFired: 150,
            type: .harjoitus,
            sportType: "IPSC",
            role: .ampuja,
            weather: "Aurinkoinen, +18°C",
            result: "87%",
            hitFactor: 5.23,
            notes: "Hyvä harjoitus, vedon hallinta parantunut",
            weapon: glock17,
            range: helsinkiRange
        )
        let session2 = Session(
            date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!,
            numberOfShotsFired: 60,
            type: .kilpailu,
            sportType: "Skeet",
            role: .ampuja,
            weather: "Pilvinen, +12°C",
            result: "22/25",
            distanceToTarget: 25,
            weapon: beretta686,
            range: jyvaskylaRange
        )
        let session3 = Session(
            date: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
            numberOfShotsFired: 50,
            type: .harjoitus,
            sportType: "Kohdistus",
            role: .ampuja,
            weather: "Sade, +8°C",
            distanceToTarget: 100,
            weapon: cz457,
            range: jyvaskylaRange
        )
        [session1, session2, session3].forEach { context.insert($0) }

        return container
    }()
}
