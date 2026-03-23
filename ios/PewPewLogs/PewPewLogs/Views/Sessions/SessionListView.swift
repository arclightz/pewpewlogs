import SwiftUI
import SwiftData

struct SessionListView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var searchText = ""
    @State private var showingNewSession = false

    var filteredSessions: [Session] {
        if searchText.isEmpty { return sessions }
        return sessions.filter { session in
            session.sportType.localizedCaseInsensitiveContains(searchText) ||
            session.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
            session.weapon?.name.localizedCaseInsensitiveContains(searchText) == true ||
            session.range?.name.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    /// Group sessions by month-year for section headers.
    var groupedSessions: [(key: String, sessions: [Session])] {
        let grouped = Dictionary(grouping: filteredSessions) { session in
            DateFormatters.monthYear.string(from: session.date)
        }
        return grouped
            .map { (key: $0.key, sessions: $0.value) }
            .sorted { lhs, rhs in
                guard let lDate = lhs.sessions.first?.date,
                      let rDate = rhs.sessions.first?.date else { return false }
                return lDate > rDate
            }
    }

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "Ei harjoitteita",
                    systemImage: "book.closed",
                    description: Text("Kirjaa ensimmäinen harjoitteesi aloittaaksesi.")
                )
            } else {
                List {
                    ForEach(groupedSessions, id: \.key) { group in
                        Section(group.key.capitalized) {
                            ForEach(group.sessions) { session in
                                NavigationLink(value: session) {
                                    SessionRowView(session: session)
                                }
                            }
                            .onDelete { indexSet in
                                // Will be handled with modelContext in Phase 4
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Hae harjoitteita…")
            }
        }
        .navigationTitle("Päiväkirja")
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewSession = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewSession) {
            NavigationStack {
                SessionFormView()
            }
        }
    }
}

// MARK: - Row View

struct SessionRowView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(session.date, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(session.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(sessionTypeBadgeColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            HStack {
                Label(session.sportType, systemImage: "target")
                    .font(.caption)
                Spacer()
                Text("\(session.numberOfShotsFired) laukausta")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let weaponName = session.weapon?.name {
                Label(weaponName, systemImage: "scope")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var sessionTypeBadgeColor: Color {
        switch session.type {
        case .kilpailu: .red
        case .harjoitus: .blue
        case .harjoituskilpailu: .orange
        case .kuivaharjoittelu: .gray
        case .seuranViikkokisa: .purple
        case .valmennus: .green
        case .muuMerkinta: .secondary
        }
    }
}

#Preview {
    NavigationStack {
        SessionListView()
    }
    .modelContainer(PreviewSampleData.container)
}
