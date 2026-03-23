import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query private var weapons: [Weapon]

    var body: some View {
        Group {
            if sessions.isEmpty {
                emptyState
            } else {
                statsContent
            }
        }
        .navigationTitle("Tilastot")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.warningGradient.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.warningGradient)
            }
            Text("Ei tilastoja")
                .font(.title2)
                .fontWeight(.bold)
            Text("Kirjaa harjoitteita nähdäksesi tilastosi.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Stats Content

    private var statsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Cards
                summaryCards

                // Shots Over Time
                shotsOverTimeCard

                // Sessions by Type
                sessionsByTypeCard

                // Per Weapon Breakdown
                perWeaponCard
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryStatCard(
                value: "\(sessions.count)",
                label: "Harjoitetta",
                icon: "flame.fill",
                gradient: AppTheme.primaryGradient
            )
            SummaryStatCard(
                value: "\(totalShots)",
                label: "Laukausta",
                icon: "burst.fill",
                gradient: AppTheme.successGradient
            )
            SummaryStatCard(
                value: averageShotsPerSession,
                label: "Ka. / harjoite",
                icon: "chart.line.uptrend.xyaxis",
                gradient: AppTheme.warningGradient
            )
        }
    }

    // MARK: - Shots Over Time

    private var shotsOverTimeCard: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(title: "Laukaukset ajan mittaan", icon: "chart.xyaxis.line")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Chart(sessions) { session in
                BarMark(
                    x: .value("Päivä", session.date, unit: .day),
                    y: .value("Laukauksia", session.numberOfShotsFired)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Sessions by Type

    private var sessionsByTypeCard: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(title: "Harjoitteet tyypeittäin", icon: "chart.pie.fill")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Chart(sessionTypeStats, id: \.type) { stat in
                SectorMark(
                    angle: .value("Määrä", stat.count),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(AppTheme.sessionTypeColor(stat.sessionType))
                .cornerRadius(4)
            }
            .frame(height: 200)
            .padding(.horizontal, 16)

            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(sessionTypeStats, id: \.type) { stat in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppTheme.sessionTypeColor(stat.sessionType))
                            .frame(width: 8, height: 8)
                        Text(stat.type)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(stat.count)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Per Weapon Breakdown

    private var perWeaponCard: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(title: "Laukauksia per ase", icon: "scope")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 4)

            VStack(spacing: 0) {
                ForEach(Array(weaponStats.enumerated()), id: \.element.weapon.persistentModelID) { index, stat in
                    if index > 0 {
                        Divider().padding(.leading, 54)
                    }

                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppTheme.weaponTypeColor(stat.weapon.type).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.weaponTypeColor(stat.weapon.type))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stat.weapon.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(stat.weapon.type.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(stat.totalShots)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .monospacedDigit()
                            Text("\(stat.sessionCount) harjoitetta")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Computed Stats

    private var totalShots: Int {
        sessions.reduce(0) { $0 + $1.numberOfShotsFired }
    }

    private var averageShotsPerSession: String {
        guard !sessions.isEmpty else { return "0" }
        return "\(totalShots / sessions.count)"
    }

    private struct WeaponStat {
        let weapon: Weapon
        let totalShots: Int
        let sessionCount: Int
    }

    private var weaponStats: [WeaponStat] {
        weapons.compactMap { weapon in
            let weaponSessions = sessions.filter { $0.weapon?.persistentModelID == weapon.persistentModelID }
            guard !weaponSessions.isEmpty else { return nil }
            return WeaponStat(
                weapon: weapon,
                totalShots: weaponSessions.reduce(0) { $0 + $1.numberOfShotsFired },
                sessionCount: weaponSessions.count
            )
        }
        .sorted { $0.totalShots > $1.totalShots }
    }

    private struct TypeStat {
        let type: String
        let sessionType: SessionType
        let count: Int
    }

    private var sessionTypeStats: [TypeStat] {
        let grouped = Dictionary(grouping: sessions) { $0.type }
        return grouped.map { TypeStat(type: $0.key.rawValue, sessionType: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

// MARK: - Summary Stat Card

private struct SummaryStatCard: View {
    let value: String
    let label: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(PreviewSampleData.container)
}
