import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query private var weapons: [Weapon]
    @Query private var ranges: [ShootingRange]

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
                summaryCards
                cumulativeShotsCard
                monthlyShotsCard
                if !hitFactorData.isEmpty {
                    hitFactorCard
                }
                if !compScoreData.isEmpty {
                    compScoreCard
                }
                sessionsByTypeCard
                perWeaponCard
                rangeUsageCard
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

    // MARK: - Cumulative Shots (line)

    private var cumulativeShotsCard: some View {
        StatChartCard(title: "Laukaukset yhteensä", icon: "chart.xyaxis.line") {
            Chart(cumulativeShotsData) { point in
                AreaMark(
                    x: .value("Päivä", point.date),
                    y: .value("Laukauksia", point.totalShots)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667EEA").opacity(0.3), Color(hex: "764BA2").opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Päivä", point.date),
                    y: .value("Laukauksia", point.totalShots)
                )
                .foregroundStyle(Color(hex: "667EEA"))
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                PointMark(
                    x: .value("Päivä", point.date),
                    y: .value("Laukauksia", point.totalShots)
                )
                .foregroundStyle(Color(hex: "764BA2"))
                .symbolSize(20)
            }
            .standardAxes()
        }
    }

    // MARK: - Monthly Shot Volume (bars)

    private var monthlyShotsCard: some View {
        StatChartCard(title: "Laukauksia per kuukausi", icon: "chart.bar.fill") {
            Chart(monthlyShotsData) { point in
                BarMark(
                    x: .value("Kuukausi", point.date, unit: .month),
                    y: .value("Laukauksia", point.shots)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "11998E"), Color(hex: "38EF7D")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
            .standardAxes(dateFormat: .dateTime.month(.abbreviated))
        }
    }

    // MARK: - Hit Factor Trend (line)

    private var hitFactorCard: some View {
        StatChartCard(title: "Hit Factor -kehitys", icon: "bolt.fill") {
            Chart(hitFactorData) { point in
                LineMark(
                    x: .value("Päivä", point.date),
                    y: .value("HF", point.value)
                )
                .foregroundStyle(Color(hex: "F2994A"))
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                PointMark(
                    x: .value("Päivä", point.date),
                    y: .value("HF", point.value)
                )
                .foregroundStyle(Color(hex: "F2994A"))
                .symbolSize(30)
                .annotation(position: .top, spacing: 4) {
                    Text(String(format: "%.1f", point.value))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(hex: "F2994A"))
                }
            }
            .standardAxes()
        }
    }

    // MARK: - Competition Scores Trend (line)

    private var compScoreCard: some View {
        StatChartCard(title: "Kilpailutulokset", icon: "trophy.fill") {
            Chart(compScoreData) { point in
                AreaMark(
                    x: .value("Päivä", point.date),
                    y: .value("%", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "EB3349").opacity(0.2), Color(hex: "F45C43").opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Päivä", point.date),
                    y: .value("%", point.value)
                )
                .foregroundStyle(Color(hex: "EB3349"))
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                PointMark(
                    x: .value("Päivä", point.date),
                    y: .value("%", point.value)
                )
                .foregroundStyle(Color(hex: "EB3349"))
                .symbolSize(30)
                .annotation(position: .top, spacing: 4) {
                    Text(String(format: "%.1f%%", point.value))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(hex: "EB3349"))
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated), centered: true)
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
        }
    }

    // MARK: - Sessions by Type (donut)

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

    // MARK: - Per Weapon Breakdown (list)

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

    // MARK: - Range Usage (horizontal bars)

    private var rangeUsageCard: some View {
        StatChartCard(title: "Ratojen käyttö", icon: "mappin.circle.fill") {
            Chart(rangeStats) { stat in
                BarMark(
                    x: .value("Käyntejä", stat.sessionCount),
                    y: .value("Rata", stat.name)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "F093FB"), Color(hex: "F5576C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(4)
                .annotation(position: .trailing, spacing: 4) {
                    Text("\(stat.sessionCount)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
        }
    }

    // MARK: - Data Models

    private struct DateValuePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    private struct CumulativeShotPoint: Identifiable {
        let id = UUID()
        let date: Date
        let totalShots: Int
    }

    private struct MonthlyShotPoint: Identifiable {
        let id = UUID()
        let date: Date
        let shots: Int
    }

    private struct WeaponStat {
        let weapon: Weapon
        let totalShots: Int
        let sessionCount: Int
    }

    private struct TypeStat {
        let type: String
        let sessionType: SessionType
        let count: Int
    }

    private struct RangeStat: Identifiable {
        let id = UUID()
        let name: String
        let sessionCount: Int
    }

    // MARK: - Computed Data

    private var totalShots: Int {
        sessions.reduce(0) { $0 + $1.numberOfShotsFired }
    }

    private var averageShotsPerSession: String {
        guard !sessions.isEmpty else { return "0" }
        return "\(totalShots / sessions.count)"
    }

    private var cumulativeShotsData: [CumulativeShotPoint] {
        let sorted = sessions.sorted { $0.date < $1.date }
        var cumulative = 0
        return sorted.map { session in
            cumulative += session.numberOfShotsFired
            return CumulativeShotPoint(date: session.date, totalShots: cumulative)
        }
    }

    private var monthlyShotsData: [MonthlyShotPoint] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            cal.dateInterval(of: .month, for: session.date)?.start ?? session.date
        }
        return grouped.map { MonthlyShotPoint(date: $0.key, shots: $0.value.reduce(0) { $0 + $1.numberOfShotsFired }) }
            .sorted { $0.date < $1.date }
    }

    private var hitFactorData: [DateValuePoint] {
        sessions.sorted { $0.date < $1.date }
            .compactMap { session in
                guard let hf = session.hitFactor else { return nil }
                return DateValuePoint(date: session.date, value: hf)
            }
    }

    private var compScoreData: [DateValuePoint] {
        sessions.sorted { $0.date < $1.date }
            .compactMap { session in
                guard let cs = session.compScore else { return nil }
                return DateValuePoint(date: session.date, value: cs)
            }
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

    private var sessionTypeStats: [TypeStat] {
        let grouped = Dictionary(grouping: sessions) { $0.type }
        return grouped.map { TypeStat(type: $0.key.rawValue, sessionType: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var rangeStats: [RangeStat] {
        let grouped = Dictionary(grouping: sessions.filter { $0.range != nil }) { $0.range!.name }
        return grouped.map { RangeStat(name: $0.key, sessionCount: $0.value.count) }
            .sorted { $0.sessionCount > $1.sessionCount }
    }
}

// MARK: - Reusable Chart Card

private struct StatChartCard<ChartContent: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let chart: () -> ChartContent

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(title: title, icon: icon)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            chart()
                .frame(height: 200)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Chart Axis Modifier

private struct StandardAxesModifier: ViewModifier {
    var dateFormat: Date.FormatStyle = .dateTime.day().month(.abbreviated)

    func body(content: Content) -> some View {
        content
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel(format: dateFormat, centered: true)
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
    }
}

extension Chart {
    func standardAxes(dateFormat: Date.FormatStyle = .dateTime.day().month(.abbreviated)) -> some View {
        modifier(StandardAxesModifier(dateFormat: dateFormat))
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
