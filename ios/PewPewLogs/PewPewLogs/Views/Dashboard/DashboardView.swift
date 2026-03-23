import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query private var weapons: [Weapon]
    @Query private var ranges: [ShootingRange]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Hero Card
                    heroCard

                    // MARK: - Quick Stats
                    statsRow

                    // MARK: - Quick Actions
                    quickActionsSection

                    // MARK: - Recent Sessions
                    if !sessions.isEmpty {
                        recentSessionsSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PewPewLogs")
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "scope")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.9))

            Text("Tervetuloa!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Joko ammutaan lisää?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            if !sessions.isEmpty {
                let totalShots = sessions.reduce(0) { $0 + $1.numberOfShotsFired }
                Text("\(totalShots) laukausta kirjattu")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: Color(hex: "667EEA").opacity(0.3), radius: 16, x: 0, y: 8)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Harjoitteet",
                value: "\(sessions.count)",
                icon: "flame.fill",
                gradient: AppTheme.primaryGradient
            )
            StatCard(
                title: "Aseet",
                value: "\(weapons.count)",
                icon: "target",
                gradient: AppTheme.accentGradient
            )
            StatCard(
                title: "Radat",
                value: "\(ranges.count)",
                icon: "mappin.circle.fill",
                gradient: AppTheme.successGradient
            )
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Pikatoiminnot", icon: "bolt.fill")

            NavigationLink {
                SessionFormView()
            } label: {
                QuickActionRow(
                    title: "Kirjaa uusi harjoite",
                    subtitle: "Lisää ampumaharjoitus tai kilpailu",
                    icon: "plus.circle.fill",
                    iconColor: Color(hex: "11998E")
                )
            }

            NavigationLink {
                WeaponFormView()
            } label: {
                QuickActionRow(
                    title: "Lisää uusi ase",
                    subtitle: "Rekisteröi ase kokoelmaasi",
                    icon: "plus.circle.fill",
                    iconColor: Color(hex: "764BA2")
                )
            }

            NavigationLink {
                RangeFormView()
            } label: {
                QuickActionRow(
                    title: "Lisää ampumarata",
                    subtitle: "Tallenna uusi ampumaratasijainti",
                    icon: "plus.circle.fill",
                    iconColor: Color(hex: "F2994A")
                )
            }
        }
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Viimeisimmät harjoitteet", icon: "clock.fill")

            ForEach(sessions.prefix(3)) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    RecentSessionRow(session: session)
                }
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(gradient.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(gradient)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Quick Action Row

private struct QuickActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
    }
}

// MARK: - Recent Session Row

private struct RecentSessionRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 14) {
            // Type indicator stripe
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.sessionTypeGradient(session.type))
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.date, format: .dateTime.day().month(.abbreviated))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(session.type.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.sessionTypeColor(session.type).opacity(0.12))
                        .foregroundStyle(AppTheme.sessionTypeColor(session.type))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                HStack {
                    Label(session.sportType, systemImage: "target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(session.numberOfShotsFired)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    if let weapon = session.weapon {
                        Text("·")
                            .foregroundStyle(.quaternary)
                        Text(weapon.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
    }
}

#Preview {
    DashboardView()
        .modelContainer(PreviewSampleData.container)
}
