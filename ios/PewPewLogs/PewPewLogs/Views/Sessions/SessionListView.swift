import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var searchText = ""
    @State private var showingNewSession = false
    @State private var sessionToEdit: Session?
    @State private var sessionToDelete: Session?
    @State private var showDeleteConfirmation = false

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
                emptyState
            } else {
                sessionList
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
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(hex: "667EEA"))
                }
            }
        }
        .sheet(isPresented: $showingNewSession) {
            NavigationStack {
                SessionFormView()
            }
        }
        .sheet(item: $sessionToEdit) { session in
            NavigationStack {
                SessionFormView(session: session)
            }
        }
        .alert("Poista harjoite?", isPresented: $showDeleteConfirmation, presenting: sessionToDelete) { session in
            Button("Poista", role: .destructive) {
                withAnimation {
                    modelContext.delete(session)
                }
            }
            Button("Peruuta", role: .cancel) {
                sessionToDelete = nil
            }
        } message: { session in
            Text("Haluatko varmasti poistaa harjoitteen (\(DateFormatters.shortDate.string(from: session.date)), \(session.sportType))? Tätä ei voi perua.")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.primaryGradient)
            }
            Text("Ei harjoitteita")
                .font(.title2)
                .fontWeight(.bold)
            Text("Kirjaa ensimmäinen harjoitteesi aloittaaksesi.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewSession = true
            } label: {
                Label("Kirjaa harjoite", systemImage: "plus.circle.fill")
                    .primaryButton(AppTheme.successGradient)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Session List

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(groupedSessions, id: \.key) { group in
                    Section {
                        ForEach(group.sessions) { session in
                            NavigationLink(value: session) {
                                SessionRowView(session: session)
                            }
                            .contextMenu {
                                Button {
                                    sessionToEdit = session
                                } label: {
                                    Label("Muokkaa", systemImage: "pencil")
                                }

                                Divider()

                                Button(role: .destructive) {
                                    sessionToDelete = session
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Poista", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(group.key.capitalized)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(group.sessions.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .searchable(text: $searchText, prompt: "Hae harjoitteita…")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Row View

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack(spacing: 14) {
            // Colored type indicator
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppTheme.sessionTypeColor(session.type).opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: sessionTypeIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.sessionTypeColor(session.type))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(session.sportType)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(session.type.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.sessionTypeColor(session.type).opacity(0.12))
                        .foregroundStyle(AppTheme.sessionTypeColor(session.type))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                HStack(spacing: 12) {
                    Label {
                        Text(session.date, format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.tertiary)
                    }
                    .font(.caption)

                    Label {
                        Text("\(session.numberOfShotsFired)")
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange.opacity(0.7))
                    }
                    .font(.caption)

                    if let weapon = session.weapon {
                        Label {
                            Text(weapon.name)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "scope")
                                .foregroundStyle(.tertiary)
                        }
                        .font(.caption)
                        .lineLimit(1)
                    }

                    Spacer()
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

    private var sessionTypeIcon: String {
        switch session.type {
        case .kilpailu: "trophy.fill"
        case .harjoitus: "figure.strengthtraining.traditional"
        case .harjoituskilpailu: "flag.fill"
        case .kuivaharjoittelu: "wind"
        case .seuranViikkokisa: "person.3.fill"
        case .valmennus: "graduationcap.fill"
        case .muuMerkinta: "note.text"
        }
    }
}

#Preview {
    NavigationStack {
        SessionListView()
    }
    .modelContainer(PreviewSampleData.container)
}
