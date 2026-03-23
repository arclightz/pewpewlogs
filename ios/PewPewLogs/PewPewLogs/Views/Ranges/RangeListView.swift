import SwiftUI
import SwiftData
import MapKit

struct RangeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShootingRange.name) private var ranges: [ShootingRange]
    @State private var showingNewRange = false
    @State private var searchText = ""

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
                ContentUnavailableView(
                    "Ei ampumaratoja",
                    systemImage: "mappin.slash",
                    description: Text("Lisää ensimmäinen ampumaratasi aloittaaksesi.")
                )
            } else {
                List {
                    ForEach(filteredRanges) { range in
                        NavigationLink(value: range) {
                            RangeRowView(range: range)
                        }
                    }
                    .onDelete(perform: deleteRanges)
                }
                .searchable(text: $searchText, prompt: "Hae ampumaratoja…")
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
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewRange) {
            NavigationStack {
                RangeFormView()
            }
        }
    }

    private func deleteRanges(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredRanges[index])
        }
    }
}

// MARK: - Row View

struct RangeRowView: View {
    let range: ShootingRange

    var body: some View {
        HStack(spacing: 12) {
            // Mini map preview
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: range.latitude, longitude: range.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))) {
                Marker(range.name, coordinate: CLLocationCoordinate2D(
                    latitude: range.latitude, longitude: range.longitude
                ))
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .allowsHitTesting(false) // Don't intercept taps

            VStack(alignment: .leading, spacing: 4) {
                Text(range.name)
                    .font(.headline)
                Text(range.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RangeListView()
    }
    .modelContainer(PreviewSampleData.container)
}
