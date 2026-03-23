import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query private var weapons: [Weapon]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "Ei tilastoja",
                    systemImage: "chart.bar",
                    description: Text("Kirjaa harjoitteita nähdäksesi tilastosi.")
                )
            } else {
                List {
                    // MARK: - Overall Stats
                    Section("Yleinen suorituskyky") {
                        LabeledContent("Harjoitteita yhteensä", value: "\(sessions.count)")
                        LabeledContent("Laukauksia yhteensä", value: "\(totalShots)")
                    }

                    // MARK: - Shots Over Time Chart
                    Section("Laukaukset ajan mittaan") {
                        Chart(sessions) { session in
                            BarMark(
                                x: .value("Päivä", session.date, unit: .day),
                                y: .value("Laukauksia", session.numberOfShotsFired)
                            )
                            .foregroundStyle(.blue.gradient)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.day().month(), centered: true)
                            }
                        }
                    }

                    // MARK: - Per Weapon Breakdown
                    Section("Laukauksia per ase") {
                        ForEach(weaponStats, id: \.weapon.persistentModelID) { stat in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stat.weapon.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(stat.weapon.type.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(stat.totalShots) laukausta")
                                        .font(.subheadline)
                                    Text("\(stat.sessionCount) harjoitetta")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // MARK: - Sessions by Type Chart
                    Section("Harjoitteet tyypeittäin") {
                        Chart(sessionTypeStats, id: \.type) { stat in
                            SectorMark(
                                angle: .value("Määrä", stat.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Tyyppi", stat.type))
                        }
                        .frame(height: 200)
                    }
                }
            }
        }
        .navigationTitle("Tilastot")
    }

    // MARK: - Computed Stats

    private var totalShots: Int {
        sessions.reduce(0) { $0 + $1.numberOfShotsFired }
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
        let count: Int
    }

    private var sessionTypeStats: [TypeStat] {
        let grouped = Dictionary(grouping: sessions) { $0.type.rawValue }
        return grouped.map { TypeStat(type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(PreviewSampleData.container)
}
