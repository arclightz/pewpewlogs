import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query private var weapons: [Weapon]
    @Query private var ranges: [ShootingRange]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Welcome Header
                    VStack(spacing: 8) {
                        Text("Tervetuloa!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Joko ammutaan lisää?")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    // MARK: - Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Harjoitteet", value: "\(sessions.count)", icon: "book.fill", color: .blue)
                        StatCard(title: "Aseet", value: "\(weapons.count)", icon: "target", color: .purple)
                        StatCard(title: "Radat", value: "\(ranges.count)", icon: "mappin", color: .green)
                    }

                    // MARK: - Quick Actions
                    VStack(spacing: 12) {
                        Text("Pikatoiminnot")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationLink {
                            SessionFormView()
                        } label: {
                            QuickActionRow(
                                title: "Kirjaa uusi harjoite",
                                icon: "plus.circle.fill",
                                color: .green
                            )
                        }

                        NavigationLink {
                            WeaponFormView()
                        } label: {
                            QuickActionRow(
                                title: "Lisää uusi ase",
                                icon: "plus.circle.fill",
                                color: .purple
                            )
                        }

                        NavigationLink {
                            RangeFormView()
                        } label: {
                            QuickActionRow(
                                title: "Lisää ampumarata",
                                icon: "plus.circle.fill",
                                color: .orange
                            )
                        }
                    }

                    // MARK: - Recent Sessions
                    if !sessions.isEmpty {
                        VStack(spacing: 12) {
                            Text("Viimeisimmät harjoitteet")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(sessions.prefix(3)) { session in
                                RecentSessionRow(session: session)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("PewPewLogs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct QuickActionRow: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RecentSessionRow: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(session.type.rawValue) — \(session.sportType)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.numberOfShotsFired) laukausta")
                    .font(.subheadline)
                if let weapon = session.weapon {
                    Text(weapon.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .modelContainer(PreviewSampleData.container)
}
