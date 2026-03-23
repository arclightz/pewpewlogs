import SwiftUI
import SwiftData

struct SessionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @Query(sort: \ShootingRange.name) private var ranges: [ShootingRange]

    // Form state
    @State private var date = Date.now
    @State private var selectedWeapon: Weapon?
    @State private var selectedRange: ShootingRange?
    @State private var numberOfShotsFired: Int = 0
    @State private var type: SessionType = .harjoitus
    @State private var sportType: String = ""
    @State private var role: SessionRole = .ampuja
    @State private var weather: String = ""

    // Optional fields
    @State private var showOptionalFields = false
    @State private var result: String = ""
    @State private var hitFactor: String = ""
    @State private var compScore: String = ""
    @State private var distanceToTarget: String = ""
    @State private var notes: String = ""

    @State private var errorMessage: String?

    /// Available sport types based on selected weapon
    private var availableSportTypes: [String] {
        guard let weapon = selectedWeapon else { return [] }
        return SportTypeMapping.sportTypes(for: weapon.type)
    }

    var body: some View {
        Form {
            // MARK: - Mandatory Fields
            Section("Pakolliset tiedot") {
                DatePicker("Päivämäärä", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "fi_FI"))

                Picker("Ampumarata", selection: $selectedRange) {
                    Text("Valitse rata").tag(nil as ShootingRange?)
                    ForEach(ranges) { range in
                        Text(range.name).tag(range as ShootingRange?)
                    }
                }

                Picker("Tyyppi", selection: $type) {
                    ForEach(SessionType.allCases) { sessionType in
                        Text(sessionType.rawValue).tag(sessionType)
                    }
                }

                Picker("Ase", selection: $selectedWeapon) {
                    Text("Valitse ase").tag(nil as Weapon?)
                    ForEach(weapons) { weapon in
                        Text("\(weapon.name) (\(weapon.type.rawValue))").tag(weapon as Weapon?)
                    }
                }
                .onChange(of: selectedWeapon) {
                    sportType = "" // Reset when weapon changes
                }

                if !availableSportTypes.isEmpty {
                    Picker("Laji", selection: $sportType) {
                        Text("Valitse laji").tag("")
                        ForEach(availableSportTypes, id: \.self) { sport in
                            Text(sport).tag(sport)
                        }
                    }
                }

                // Shot counter with quick-add buttons
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Laukauksia")
                        Spacer()
                        Text("\(numberOfShotsFired)")
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    HStack(spacing: 8) {
                        ForEach([10, 25, 50, 100], id: \.self) { amount in
                            Button("+\(amount)") {
                                numberOfShotsFired += amount
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        Spacer()
                        Button("Nollaa") {
                            numberOfShotsFired = 0
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(.red)
                    }
                }

                Picker("Rooli", selection: $role) {
                    ForEach(SessionRole.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }

                TextField("Sää", text: $weather, prompt: Text("esim. Aurinkoinen, +15°C"))
            }

            // MARK: - Optional Fields
            Section {
                DisclosureGroup("Valinnaiset kentät", isExpanded: $showOptionalFields) {
                    TextField("Tulos (pisteet/aika)", text: $result)
                    TextField("Hit Factor", text: $hitFactor)
                        .keyboardType(.decimalPad)
                    TextField("Kilpailutulos (%)", text: $compScore)
                        .keyboardType(.decimalPad)
                    TextField("Etäisyys maaliin (m)", text: $distanceToTarget)
                        .keyboardType(.numberPad)
                    TextField("Muistiinpanot", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }

            // MARK: - Error
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            // MARK: - Submit
            Section {
                Button("Kirjaa suoritus") {
                    saveSession()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("Uusi harjoite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") { dismiss() }
            }
        }
    }

    private var isFormValid: Bool {
        selectedWeapon != nil &&
        selectedRange != nil &&
        !sportType.isEmpty
    }

    private func saveSession() {
        guard isFormValid else {
            errorMessage = "Täytä kaikki pakolliset kentät."
            return
        }

        let session = Session(
            date: date,
            numberOfShotsFired: numberOfShotsFired,
            type: type,
            sportType: sportType,
            role: role,
            weather: weather.isEmpty ? nil : weather,
            result: result.isEmpty ? nil : result,
            hitFactor: Double(hitFactor.replacingOccurrences(of: ",", with: ".")),
            compScore: Double(compScore.replacingOccurrences(of: ",", with: ".")),
            distanceToTarget: Double(distanceToTarget),
            notes: notes.isEmpty ? nil : notes,
            weapon: selectedWeapon,
            range: selectedRange
        )

        modelContext.insert(session)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SessionFormView()
    }
    .modelContainer(PreviewSampleData.container)
}
