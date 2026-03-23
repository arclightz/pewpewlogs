import SwiftUI

struct WeaponDetailView: View {
    let weapon: Weapon

    var body: some View {
        List {
            Section("Perustiedot") {
                LabeledContent("Nimi", value: weapon.name)
                LabeledContent("Tyyppi", value: weapon.type.rawValue)
                if let caliber = weapon.caliber {
                    LabeledContent("Kaliiberi", value: caliber)
                }
                LabeledContent("ERVA", value: weapon.erva ? "Kyllä" : "Ei")
            }

            Section("Lisätiedot") {
                if let date = weapon.purchaseDate {
                    LabeledContent("Hankintapäivä", value: date, format: .dateTime.day().month().year())
                }
                if let notes = weapon.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Muistiinpanot")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(notes)
                    }
                }
            }

            if !weapon.sessions.isEmpty {
                Section("Käyttöhistoria") {
                    LabeledContent("Harjoitteita", value: "\(weapon.sessions.count)")
                    LabeledContent("Laukauksia yhteensä", value: "\(weapon.sessions.reduce(0) { $0 + $1.numberOfShotsFired })")
                }
            }

            Section("Tiedot") {
                LabeledContent("Luotu", value: weapon.createdAt, format: .dateTime)
                LabeledContent("Päivitetty", value: weapon.updatedAt, format: .dateTime)
            }
        }
        .navigationTitle(weapon.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WeaponDetailView(weapon: Weapon(
            name: "Glock 17",
            type: .pistooli,
            caliber: "9x19mm",
            erva: false,
            notes: "Kilpailukäyttöön"
        ))
    }
}
