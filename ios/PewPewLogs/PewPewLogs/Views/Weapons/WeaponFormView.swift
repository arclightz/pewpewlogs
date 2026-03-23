import SwiftUI

struct WeaponFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Edit mode
    var weaponToEdit: Weapon?
    private var isEditing: Bool { weaponToEdit != nil }

    @State private var name = ""
    @State private var type: WeaponType = .pistooli
    @State private var caliber = ""
    @State private var erva = false
    @State private var purchaseDate: Date? = nil
    @State private var showPurchaseDate = false
    @State private var notes = ""
    @State private var errorMessage: String?

    init(weapon: Weapon? = nil) {
        self.weaponToEdit = weapon
        if let weapon {
            _name = State(initialValue: weapon.name)
            _type = State(initialValue: weapon.type)
            _caliber = State(initialValue: weapon.caliber ?? "")
            _erva = State(initialValue: weapon.erva)
            _purchaseDate = State(initialValue: weapon.purchaseDate)
            _showPurchaseDate = State(initialValue: weapon.purchaseDate != nil)
            _notes = State(initialValue: weapon.notes ?? "")
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Aseen nimi", text: $name)
                Picker("Tyyppi", selection: $type) {
                    ForEach(WeaponType.allCases) { weaponType in
                        Text(weaponType.rawValue).tag(weaponType)
                    }
                }
                TextField("Kaliiberi", text: $caliber, prompt: Text("esim. 9x19mm"))
                Toggle("ERVA-ase", isOn: $erva)
                    .tint(Color(hex: "F2994A"))
            } header: {
                Label("Perustiedot", systemImage: "info.circle.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "764BA2"))
            }

            Section {
                Toggle("Hankintapäivä", isOn: $showPurchaseDate)
                    .tint(Color(hex: "667EEA"))
                if showPurchaseDate {
                    DatePicker(
                        "Päivämäärä",
                        selection: Binding(
                            get: { purchaseDate ?? .now },
                            set: { purchaseDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .environment(\.locale, Locale(identifier: "fi_FI"))
                }
                TextField("Muistiinpanot", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            } header: {
                Label("Lisätiedot", systemImage: "ellipsis.circle.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            Section {
                Button {
                    saveWeapon()
                } label: {
                    Label(isEditing ? "Tallenna muutokset" : "Tallenna ase",
                          systemImage: "checkmark.circle.fill")
                        .primaryButton(AppTheme.accentGradient)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
        .navigationTitle(isEditing ? "Muokkaa asetta" : "Uusi ase")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") { dismiss() }
            }
        }
    }

    private func saveWeapon() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "Aseen nimi vaaditaan."
            return
        }

        if let weapon = weaponToEdit {
            // Update existing
            weapon.name = trimmedName
            weapon.type = type
            weapon.caliber = caliber.isEmpty ? nil : caliber
            weapon.erva = erva
            weapon.purchaseDate = showPurchaseDate ? (purchaseDate ?? .now) : nil
            weapon.notes = notes.isEmpty ? nil : notes
            weapon.updatedAt = .now
        } else {
            // Create new
            let weapon = Weapon(
                name: trimmedName,
                type: type,
                caliber: caliber.isEmpty ? nil : caliber,
                erva: erva,
                purchaseDate: showPurchaseDate ? (purchaseDate ?? .now) : nil,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(weapon)
        }
        dismiss()
    }
}

#Preview("Uusi") {
    NavigationStack {
        WeaponFormView()
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Muokkaa") {
    NavigationStack {
        WeaponFormView(weapon: Weapon(
            name: "Glock 17",
            type: .pistooli,
            caliber: "9x19mm",
            erva: false,
            notes: "Kilpailukäyttöön"
        ))
    }
    .modelContainer(PreviewSampleData.container)
}
