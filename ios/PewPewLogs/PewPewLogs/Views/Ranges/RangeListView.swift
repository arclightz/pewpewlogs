import SwiftUI
import SwiftData
import MapKit

struct RangeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShootingRange.name) private var ranges: [ShootingRange]
    @State private var showingNewRange = false
    @State private var searchText = ""
    @State private var rangeToEdit: ShootingRange?
    @State private var rangeToDelete: ShootingRange?
    @State private var showDeleteConfirmation = false

    var filteredRanges: [ShootingRange] {
        if searchText.isEmpty { return ranges }
        return ranges.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if ranges.isEmpty {
                emptyState
            } else {
                rangeList
            }
        }
        .navigationTitle("Ampumaradat")
        .navigationDestination(for: ShootingRange.self) { range in
            RangeDetailView(range: range)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewRange = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(hex: "F2994A"))
                }
            }
        }
        .sheet(isPresented: $showingNewRange) {
            NavigationStack {
                RangeFormView()
            }
        }
        .sheet(item: $rangeToEdit) { range in
            NavigationStack {
                RangeFormView(range: range)
            }
        }
        .alert("Poista ampumarata?", isPresented: $showDeleteConfirmation, presenting: rangeToDelete) { range in
            Button("Poista", role: .destructive) {
                withAnimation {
                    modelContext.delete(range)
                }
            }
            Button("Peruuta", role: .cancel) {
                rangeToDelete = nil
            }
        } message: { range in
            if range.sessions.isEmpty {
                Text("Haluatko varmasti poistaa ampumaradan \"\(range.name)\"? Tätä ei voi perua.")
            } else {
                Text("Haluatko varmasti poistaa ampumaradan \"\(range.name)\"? Rata on käytössä \(range.sessions.count) harjoitteessa. Tätä ei voi perua.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.warningGradient.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "mappin.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.warningGradient)
            }
            Text("Ei ampumaratoja")
                .font(.title2)
                .fontWeight(.bold)
            Text("Lisää ensimmäinen ampumaratasi aloittaaksesi.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewRange = true
            } label: {
                Label("Lisää ampumarata", systemImage: "plus.circle.fill")
                    .primaryButton(AppTheme.warningGradient)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Range List

    private var rangeList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredRanges) { range in
                    NavigationLink(value: range) {
                        RangeRowView(range: range)
                    }
                    .contextMenu {
                        Button {
                            rangeToEdit = range
                        } label: {
                            Label("Muokkaa", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            rangeToDelete = range
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
        .searchable(text: $searchText, prompt: "Hae ampumaratoja…")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Row View

struct RangeRowView: View {
    let range: ShootingRange

    var body: some View {
        VStack(spacing: 0) {
            // Map preview
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: range.latitude, longitude: range.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            ))) {
                Marker(range.name, coordinate: CLLocationCoordinate2D(
                    latitude: range.latitude, longitude: range.longitude
                ))
                .tint(Color(hex: "F2994A"))
            }
            .frame(height: 120)
            .allowsHitTesting(false)

            // Info section
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: "F2994A").opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: "F2994A"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(range.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(range.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if !range.sessions.isEmpty {
                    VStack(spacing: 2) {
                        Text("\(range.sessions.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "F2994A"))
                        Text("käyntiä")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.quaternary)
            }
            .padding(14)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        RangeListView()
    }
    .modelContainer(PreviewSampleData.container)
}
