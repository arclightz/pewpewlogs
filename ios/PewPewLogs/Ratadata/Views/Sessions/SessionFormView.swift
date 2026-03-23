import SwiftUI
import SwiftData

struct SessionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @Query(sort: \ShootingRange.name) private var ranges: [ShootingRange]

    // Edit mode
    var sessionToEdit: Session?
    private var isEditing: Bool { sessionToEdit != nil }

    // Form state — use value types (PersistentIdentifier) for reliable @State re-renders
    @State private var date = Date.now
    @State private var selectedWeaponID: PersistentIdentifier?
    @State private var selectedRangeID: PersistentIdentifier?
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

    init(session: Session? = nil) {
        self.sessionToEdit = session
        if let session {
            _date = State(initialValue: session.date)
            _selectedWeaponID = State(initialValue: session.weapon?.persistentModelID)
            _selectedRangeID = State(initialValue: session.range?.persistentModelID)
            _numberOfShotsFired = State(initialValue: session.numberOfShotsFired)
            _type = State(initialValue: session.type)
            _sportType = State(initialValue: session.sportType)
            _role = State(initialValue: session.role)
            _weather = State(initialValue: session.weather ?? "")
            _result = State(initialValue: session.result ?? "")
            _hitFactor = State(initialValue: session.hitFactor.map { String($0) } ?? "")
            _compScore = State(initialValue: session.compScore.map { String($0) } ?? "")
            _distanceToTarget = State(initialValue: session.distanceToTarget.map { String(Int($0)) } ?? "")
            _notes = State(initialValue: session.notes ?? "")
            _showOptionalFields = State(initialValue:
                session.result != nil || session.hitFactor != nil ||
                session.compScore != nil || session.distanceToTarget != nil ||
                (session.notes != nil && !session.notes!.isEmpty)
            )
        }
    }

    // Resolve IDs to model objects
    private var selectedWeapon: Weapon? {
        guard let id = selectedWeaponID else { return nil }
        return weapons.first { $0.persistentModelID == id }
    }

    private var selectedRange: ShootingRange? {
        guard let id = selectedRangeID else { return nil }
        return ranges.first { $0.persistentModelID == id }
    }

    /// Available sport types based on selected weapon
    private var availableSportTypes: [String] {
        guard let weapon = selectedWeapon else { return [] }
        return SportTypeMapping.sportTypes(for: weapon.type)
    }

    var body: some View {
        Form {
            // MARK: - Mandatory Fields
            Section {
                DatePicker("Päivämäärä", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "fi_FI"))

                // Range picker — using Menu for reliable selection
                HStack {
                    Text("Ampumarata")
                    Spacer()
                    Menu {
                        ForEach(ranges) { range in
                            Button {
                                selectedRangeID = range.persistentModelID
                            } label: {
                                if selectedRangeID == range.persistentModelID {
                                    Label(range.name, systemImage: "checkmark")
                                } else {
                                    Text(range.name)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedRange?.name ?? "Valitse rata")
                                .foregroundStyle(selectedRange == nil ? .secondary : .primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Picker("Tyyppi", selection: $type) {
                    ForEach(SessionType.allCases) { sessionType in
                        Text(sessionType.rawValue).tag(sessionType)
                    }
                }

                // Weapon picker — using Menu for reliable selection
                HStack {
                    Text("Ase")
                    Spacer()
                    Menu {
                        ForEach(weapons) { weapon in
                            Button {
                                let changed = selectedWeaponID != weapon.persistentModelID
                                selectedWeaponID = weapon.persistentModelID
                                if changed {
                                    sportType = ""
                                }
                            } label: {
                                if selectedWeaponID == weapon.persistentModelID {
                                    Label("\(weapon.name) (\(weapon.type.rawValue))", systemImage: "checkmark")
                                } else {
                                    Text("\(weapon.name) (\(weapon.type.rawValue))")
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedWeapon.map { "\($0.name) (\($0.type.rawValue))" } ?? "Valitse ase")
                                .foregroundStyle(selectedWeapon == nil ? .secondary : .primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Sport type picker — using Menu
                if !availableSportTypes.isEmpty {
                    HStack {
                        Text("Laji")
                        Spacer()
                        Menu {
                            ForEach(availableSportTypes, id: \.self) { sport in
                                Button {
                                    sportType = sport
                                } label: {
                                    if sportType == sport {
                                        Label(sport, systemImage: "checkmark")
                                    } else {
                                        Text(sport)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(sportType.isEmpty ? "Valitse laji" : sportType)
                                    .foregroundStyle(sportType.isEmpty ? .secondary : .primary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Shot counter: manual entry + quick-add buttons
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Laukauksia")
                        Spacer()
                        TextField("0", value: $numberOfShotsFired, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(Color(hex: "667EEA"))
                            .frame(width: 100)
                    }
                    HStack(spacing: 8) {
                        ForEach([10, 25, 50, 100], id: \.self) { amount in
                            Button("+\(amount)") {
                                withAnimation(.snappy(duration: 0.2)) {
                                    numberOfShotsFired += amount
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "667EEA").opacity(0.1))
                            .foregroundStyle(Color(hex: "667EEA"))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        Spacer()
                        Button("Nollaa") {
                            withAnimation(.snappy(duration: 0.2)) {
                                numberOfShotsFired = 0
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                Picker("Rooli", selection: $role) {
                    ForEach(SessionRole.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }

                TextField("Sää", text: $weather, prompt: Text("esim. Aurinkoinen, +15°C"))
            } header: {
                Label("Pakolliset tiedot", systemImage: "asterisk")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "667EEA"))
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
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            // MARK: - Submit
            Section {
                Button {
                    saveSession()
                } label: {
                    Label(isEditing ? "Tallenna muutokset" : "Kirjaa suoritus",
                          systemImage: "checkmark.circle.fill")
                        .primaryButton(AppTheme.successGradient)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.5)
            }
        }
        .navigationTitle(isEditing ? "Muokkaa harjoitetta" : "Uusi harjoite")
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
        guard let weapon = selectedWeapon, let range = selectedRange, !sportType.isEmpty else {
            errorMessage = "Täytä kaikki pakolliset kentät."
            return
        }

        if let session = sessionToEdit {
            // Update existing
            session.date = date
            session.numberOfShotsFired = numberOfShotsFired
            session.type = type
            session.sportType = sportType
            session.role = role
            session.weather = weather.isEmpty ? nil : weather
            session.result = result.isEmpty ? nil : result
            session.hitFactor = Double(hitFactor.replacingOccurrences(of: ",", with: "."))
            session.compScore = Double(compScore.replacingOccurrences(of: ",", with: "."))
            session.distanceToTarget = Double(distanceToTarget)
            session.notes = notes.isEmpty ? nil : notes
            session.weapon = weapon
            session.range = range
            session.updatedAt = .now
        } else {
            // Create new
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
                weapon: weapon,
                range: range
            )
            modelContext.insert(session)
        }
        dismiss()
    }
}

#Preview("Uusi") {
    NavigationStack {
        SessionFormView()
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Muokkaa") {
    NavigationStack {
        SessionFormView(session: Session(
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
    .modelContainer(PreviewSampleData.container)
}
