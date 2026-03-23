import SwiftUI
import SwiftData

struct WeaponListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @State private var showingNewWeapon = false
    @State private var searchText = ""
    @State private var weaponToEdit: Weapon?
    @State private var weaponToDelete: Weapon?
    @State private var showDeleteConfirmation = false

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
                emptyState
            } else {
                weaponList
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
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(hex: "764BA2"))
                }
            }
        }
        .sheet(isPresented: $showingNewWeapon) {
            NavigationStack {
                WeaponFormView()
            }
        }
        .sheet(item: $weaponToEdit) { weapon in
            NavigationStack {
                WeaponFormView(weapon: weapon)
            }
        }
        .alert("Poista ase?", isPresented: $showDeleteConfirmation, presenting: weaponToDelete) { weapon in
            Button("Poista", role: .destructive) {
                withAnimation {
                    modelContext.delete(weapon)
                }
            }
            Button("Peruuta", role: .cancel) {
                weaponToDelete = nil
            }
        } message: { weapon in
            if weapon.sessions.isEmpty {
                Text("Haluatko varmasti poistaa aseen \"\(weapon.name)\"? Tätä ei voi perua.")
            } else {
                Text("Haluatko varmasti poistaa aseen \"\(weapon.name)\"? Ase on käytössä \(weapon.sessions.count) harjoitteessa. Tätä ei voi perua.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGradient.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "target")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.accentGradient)
            }
            Text("Ei aseita")
                .font(.title2)
                .fontWeight(.bold)
            Text("Lisää ensimmäinen aseesi aloittaaksesi.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewWeapon = true
            } label: {
                Label("Lisää ase", systemImage: "plus.circle.fill")
                    .primaryButton(AppTheme.accentGradient)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Weapon List

    private var weaponList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredWeapons) { weapon in
                    NavigationLink(value: weapon) {
                        WeaponRowView(weapon: weapon)
                    }
                    .contextMenu {
                        Button {
                            weaponToEdit = weapon
                        } label: {
                            Label("Muokkaa", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            weaponToDelete = weapon
                            showDeleteConfirmation = true
                        } label: {
                            Label("Poista", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .searchable(text: $searchText, prompt: "Hae aseita…")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Row View

struct WeaponRowView: View {
    let weapon: Weapon

    var body: some View {
        HStack(spacing: 14) {
            // Weapon type icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.weaponTypeColor(weapon.type).opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: weaponTypeIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.weaponTypeColor(weapon.type))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(weapon.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(weapon.type.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.weaponTypeColor(weapon.type).opacity(0.12))
                        .foregroundStyle(AppTheme.weaponTypeColor(weapon.type))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                HStack(spacing: 10) {
                    if let caliber = weapon.caliber {
                        Label {
                            Text(caliber)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "circle.circle")
                                .foregroundStyle(.tertiary)
                        }
                        .font(.caption)
                    }

                    if weapon.erva {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.caption2)
                            Text("ERVA")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }

                    if !weapon.sessions.isEmpty {
                        Spacer()
                        Label {
                            Text("\(weapon.sessions.count)")
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange.opacity(0.6))
                        }
                        .font(.caption)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.quaternary)
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
    }

    private var weaponTypeIcon: String {
        switch weapon.type {
        case .pistooli: "target"
        case .kivaari: "scope"
        case .haulikko: "lines.measurement.horizontal"
        case .revolveri: "circle.hexagonpath"
        case .pcc: "bolt.horizontal.fill"
        case .ilmaAse: "wind"
        case .deaktivoitu: "lock.fill"
        case .muu: "questionmark.circle"
        case .yhdistelmaase: "square.stack.fill"
        case .merkinantoase: "light.beacon.max.fill"
        case .kaasuase: "aqi.medium"
        }
    }
}

#Preview {
    NavigationStack {
        WeaponListView()
    }
    .modelContainer(PreviewSampleData.container)
}
