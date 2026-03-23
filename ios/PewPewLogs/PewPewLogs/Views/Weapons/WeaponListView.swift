import SwiftUI
import SwiftData

struct WeaponListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @State private var showingNewWeapon = false
    @State private var searchText = ""

    var filteredWeapons: [Weapon] {
        if searchText.isEmpty { return weapons }
        return weapons.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
            ($0.caliber?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        Group {
            if weapons.isEmpty {
                ContentUnavailableView(
                    "Ei aseita",
                    systemImage: "target",
                    description: Text("Lisää ensimmäinen aseesi aloittaaksesi.")
                )
            } else {
                List {
                    ForEach(filteredWeapons) { weapon in
                        NavigationLink(value: weapon) {
                            WeaponRowView(weapon: weapon)
                        }
                    }
                    .onDelete(perform: deleteWeapons)
                }
                .searchable(text: $searchText, prompt: "Hae aseita…")
            }
        }
        .navigationTitle("Aseet")
        .navigationDestination(for: Weapon.self) { weapon in
            WeaponDetailView(weapon: weapon)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewWeapon = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewWeapon) {
            NavigationStack {
                WeaponFormView()
            }
        }
    }

    private func deleteWeapons(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredWeapons[index])
        }
    }
}

// MARK: - Row View

struct WeaponRowView: View {
    let weapon: Weapon

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(weapon.name)
                    .font(.headline)
                Spacer()
                Text(weapon.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.2))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            HStack {
                if let caliber = weapon.caliber {
                    Label(caliber, systemImage: "circle.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if weapon.erva {
                    Label("ERVA", systemImage: "checkmark.shield.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        WeaponListView()
    }
    .modelContainer(PreviewSampleData.container)
}
