import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        List {
            // MARK: - Basic Info
            Section("Perustiedot") {
                LabeledContent("Päivämäärä", value: session.date, format: .dateTime.day().month().year())
                LabeledContent("Tyyppi", value: session.type.rawValue)
                LabeledContent("Laji", value: session.sportType)
                LabeledContent("Rooli", value: session.role.rawValue)
                LabeledContent("Laukauksia", value: "\(session.numberOfShotsFired)")
            }

            // MARK: - Weapon & Range
            Section("Ase ja rata") {
                if let weapon = session.weapon {
                    LabeledContent("Ase", value: "\(weapon.name) (\(weapon.type.rawValue))")
                }
                if let range = session.range {
                    LabeledContent("Ampumarata", value: range.name)
                }
            }

            // MARK: - Optional Fields
            if hasOptionalData {
                Section("Lisätiedot") {
                    if let weather = session.weather, !weather.isEmpty {
                        LabeledContent("Sää", value: weather)
                    }
                    if let result = session.result, !result.isEmpty {
                        LabeledContent("Tulos", value: result)
                    }
                    if let hf = session.hitFactor {
                        LabeledContent("Hit Factor", value: String(format: "%.2f", hf))
                    }
                    if let cs = session.compScore {
                        LabeledContent("Kilpailutulos", value: String(format: "%.1f%%", cs))
                    }
                    if let dist = session.distanceToTarget {
                        LabeledContent("Etäisyys", value: "\(Int(dist)) m")
                    }
                    if let notes = session.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Muistiinpanot")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(notes)
                        }
                    }
                }
            }

            // MARK: - Metadata
            Section("Tiedot") {
                LabeledContent("Luotu", value: session.createdAt, format: .dateTime)
                LabeledContent("Päivitetty", value: session.updatedAt, format: .dateTime)
            }
        }
        .navigationTitle("Harjoite")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hasOptionalData: Bool {
        session.weather != nil || session.result != nil ||
        session.hitFactor != nil || session.compScore != nil ||
        session.distanceToTarget != nil || session.notes != nil
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: Session(
            date: .now,
            numberOfShotsFired: 150,
            type: .harjoitus,
            sportType: "IPSC",
            role: .ampuja,
            weather: "Aurinkoinen, +18°C",
            result: "87%",
            hitFactor: 5.23,
            notes: "Hyvä harjoitus"
        ))
    }
}
