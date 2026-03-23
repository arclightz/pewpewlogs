import SwiftUI

struct WeaponDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let weapon: Weapon

    @State private var showingEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Hero Header
                heroHeader

                VStack(spacing: 16) {
                    basicInfoCard
                    additionalInfoCard
                    if !weapon.sessions.isEmpty {
                        usageCard
                    }
                    metadataCard
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(weapon.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Muokkaa", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Poista", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                WeaponFormView(weapon: weapon)
            }
        }
        .alert("Poista ase?", isPresented: $showDeleteConfirmation) {
            Button("Poista", role: .destructive) {
                modelContext.delete(weapon)
                dismiss()
            }
            Button("Peruuta", role: .cancel) {}
        } message: {
            if weapon.sessions.isEmpty {
                Text("Haluatko varmasti poistaa aseen \"\(weapon.name)\"? Tätä ei voi perua.")
            } else {
                Text("Haluatko varmasti poistaa aseen \"\(weapon.name)\"? Ase on käytössä \(weapon.sessions.count) harjoitteessa. Tätä ei voi perua.")
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: "scope")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text(weapon.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(weapon.type.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack(spacing: 20) {
                if let caliber = weapon.caliber {
                    VStack(spacing: 2) {
                        Text(caliber)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Kaliiberi")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                if weapon.erva {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("ERVA")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                if !weapon.sessions.isEmpty {
                    VStack(spacing: 2) {
                        Text("\(weapon.sessions.count)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Harjoitetta")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal)
        .background(
            LinearGradient(
                colors: [AppTheme.weaponTypeColor(weapon.type), AppTheme.weaponTypeColor(weapon.type).opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Basic Info

    private var basicInfoCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Perustiedot", icon: "info.circle.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Nimi", value: weapon.name, icon: "textformat")
                Divider().padding(.leading, 44)
                DetailRow(label: "Tyyppi", value: weapon.type.rawValue, icon: "tag.fill")
                if let caliber = weapon.caliber {
                    Divider().padding(.leading, 44)
                    DetailRow(label: "Kaliiberi", value: caliber, icon: "circle.circle")
                }
                Divider().padding(.leading, 44)
                DetailRow(label: "ERVA", value: weapon.erva ? "Kyllä" : "Ei", icon: "checkmark.shield.fill")
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Additional Info

    private var additionalInfoCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Lisätiedot", icon: "ellipsis.circle.fill")

            VStack(spacing: 0) {
                if let date = weapon.purchaseDate {
                    DetailRow(label: "Hankintapäivä", value: DateFormatters.longDate.string(from: date), icon: "calendar")
                }
                if let notes = weapon.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "note.text")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text("Muistiinpanot")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(notes)
                            .font(.subheadline)
                            .padding(.leading, 34)
                    }
                    .padding(14)
                }
                if weapon.purchaseDate == nil && (weapon.notes == nil || weapon.notes?.isEmpty == true) {
                    HStack {
                        Text("Ei lisätietoja")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Usage Stats

    private var usageCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Käyttöhistoria", icon: "chart.bar.fill")

            HStack(spacing: 0) {
                usageStat(
                    value: "\(weapon.sessions.count)",
                    label: "Harjoitetta",
                    icon: "flame.fill",
                    color: .orange
                )

                Divider().frame(height: 50)

                usageStat(
                    value: "\(weapon.sessions.reduce(0) { $0 + $1.numberOfShotsFired })",
                    label: "Laukausta",
                    icon: "burst.fill",
                    color: Color(hex: "667EEA")
                )
            }
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    private func usageStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Metadata

    private var metadataCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Tiedot", icon: "clock.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Luotu", value: DateFormatters.shortDate.string(from: weapon.createdAt), icon: "plus.circle")
                Divider().padding(.leading, 44)
                DetailRow(label: "Päivitetty", value: DateFormatters.shortDate.string(from: weapon.updatedAt), icon: "pencil.circle")
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
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
