import SwiftUI

struct WeaponFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: WeaponType = .pistooli
    @State private var caliber = ""
    @State private var erva = false
    @State private var purchaseDate: Date? = nil
    @State private var showPurchaseDate = false
    @State private var notes = ""
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Perustiedot") {
                TextField("Aseen nimi", text: $name)
                Picker("Tyyppi", selection: $type) {
                    ForEach(WeaponType.allCases) { weaponType in
                        Text(weaponType.rawValue).tag(weaponType)
                    }
                }
                TextField("Kaliiberi", text: $caliber, prompt: Text("esim. 9x19mm"))
                Toggle("ERVA-ase", isOn: $erva)
            }

            Section("Lisätiedot") {
                Toggle("Hankintapäivä", isOn: $showPurchaseDate)
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
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Tallenna ase") {
                    saveWeapon()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Uusi ase")
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

        let weapon = Weapon(
            name: trimmedName,
            type: type,
            caliber: caliber.isEmpty ? nil : caliber,
            erva: erva,
            purchaseDate: showPurchaseDate ? (purchaseDate ?? .now) : nil,
            notes: notes.isEmpty ? nil : notes
        )

        modelContext.insert(weapon)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        WeaponFormView()
    }
    .modelContainer(PreviewSampleData.container)
}
