import SwiftUI
import MapKit

struct RangeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var latitude: Double = 62.2426 // Default: Jyväskylä
    @State private var longitude: Double = 25.7473
    @State private var website = ""
    @State private var phoneNumber = ""
    @State private var notes = ""
    @State private var errorMessage: String?

    // Map state
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 62.2426, longitude: 25.7473),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    // Search
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false

    var body: some View {
        Form {
            Section("Perustiedot") {
                TextField("Ampumaradan nimi", text: $name)
                TextField("Osoite", text: $address)
            }

            // MARK: - Address Search
            Section("Hae sijainti") {
                HStack {
                    TextField("Hae osoitetta tai paikkaa…", text: $searchText)
                        .textContentType(.fullStreetAddress)
                        .onSubmit { performSearch() }
                    if isSearching {
                        ProgressView()
                    } else {
                        Button("Hae") { performSearch() }
                            .disabled(searchText.count < 3)
                    }
                }

                if !searchResults.isEmpty {
                    ForEach(searchResults, id: \.self) { item in
                        Button {
                            selectSearchResult(item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Tuntematon")
                                    .font(.subheadline)
                                if let subtitle = item.placemark.formattedAddress {
                                    Text(subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }

            // MARK: - Map
            Section("Sijainti kartalla") {
                Map(position: $cameraPosition) {
                    Marker(name.isEmpty ? "Ampumarata" : name,
                           coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listRowInsets(EdgeInsets())

                Text("Lat: \(String(format: "%.6f", latitude)), Lng: \(String(format: "%.6f", longitude))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Yhteystiedot") {
                TextField("Verkkosivusto", text: $website, prompt: Text("https://..."))
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                TextField("Puhelinnumero", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Muistiinpanot", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Tallenna ampumarata") {
                    saveRange()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                          address.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Uusi ampumarata")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") { dismiss() }
            }
        }
    }

    // MARK: - Search

    private func performSearch() {
        guard searchText.count >= 3 else { return }
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        )
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            searchResults = response?.mapItems ?? []
        }
    }

    private func selectSearchResult(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        latitude = coord.latitude
        longitude = coord.longitude
        address = item.placemark.formattedAddress ?? item.name ?? ""
        cameraPosition = .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        searchResults = []
        searchText = ""
    }

    // MARK: - Save

    private func saveRange() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedAddress.isEmpty else {
            errorMessage = "Nimi ja osoite vaaditaan."
            return
        }

        let range = ShootingRange(
            name: trimmedName,
            address: trimmedAddress,
            latitude: latitude,
            longitude: longitude,
            notes: notes.isEmpty ? nil : notes,
            website: website.isEmpty ? nil : website,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
        )

        modelContext.insert(range)
        dismiss()
    }
}

// MARK: - Placemark Extension

extension CLPlacemark {
    var formattedAddress: String? {
        let parts = [
            thoroughfare, // street
            subThoroughfare, // number
        ].compactMap { $0 }
        let street = parts.joined(separator: " ")

        let cityParts = [
            postalCode,
            locality
        ].compactMap { $0 }
        let city = cityParts.joined(separator: " ")

        return [street, city].filter { !$0.isEmpty }.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        RangeFormView()
    }
    .modelContainer(PreviewSampleData.container)
}
