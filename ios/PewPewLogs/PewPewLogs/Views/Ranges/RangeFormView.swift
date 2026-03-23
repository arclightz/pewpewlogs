import SwiftUI
import MapKit

struct RangeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Edit mode
    var rangeToEdit: ShootingRange?
    private var isEditing: Bool { rangeToEdit != nil }

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

    init(range: ShootingRange? = nil) {
        self.rangeToEdit = range
        if let range {
            _name = State(initialValue: range.name)
            _address = State(initialValue: range.address)
            _latitude = State(initialValue: range.latitude)
            _longitude = State(initialValue: range.longitude)
            _website = State(initialValue: range.website ?? "")
            _phoneNumber = State(initialValue: range.phoneNumber ?? "")
            _notes = State(initialValue: range.notes ?? "")
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: range.latitude, longitude: range.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Ampumaradan nimi", text: $name)
                TextField("Osoite", text: $address)
            } header: {
                Label("Perustiedot", systemImage: "info.circle.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F2994A"))
            }

            // MARK: - Address Search
            Section {
                HStack {
                    TextField("Hae osoitetta tai paikkaa…", text: $searchText)
                        .textContentType(.fullStreetAddress)
                        .onSubmit { performSearch() }
                    if isSearching {
                        ProgressView()
                    } else {
                        Button {
                            performSearch()
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color(hex: "F2994A"))
                        }
                        .disabled(searchText.count < 3)
                    }
                }

                if !searchResults.isEmpty {
                    ForEach(searchResults, id: \.self) { item in
                        Button {
                            selectSearchResult(item)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(Color(hex: "F2994A"))
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Tuntematon")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
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
            } header: {
                Label("Hae sijainti", systemImage: "magnifyingglass")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Map
            Section {
                Map(position: $cameraPosition) {
                    Marker(name.isEmpty ? "Ampumarata" : name,
                           coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    .tint(Color(hex: "F2994A"))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .listRowInsets(EdgeInsets())

                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundStyle(Color(hex: "F2994A"))
                    Text("Lat: \(String(format: "%.6f", latitude)), Lng: \(String(format: "%.6f", longitude))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            } header: {
                Label("Sijainti kartalla", systemImage: "map.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Section {
                TextField("Verkkosivusto", text: $website, prompt: Text("https://..."))
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                TextField("Puhelinnumero", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Muistiinpanot", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            } header: {
                Label("Yhteystiedot", systemImage: "phone.circle.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            Section {
                Button {
                    saveRange()
                } label: {
                    Label(isEditing ? "Tallenna muutokset" : "Tallenna ampumarata",
                          systemImage: "checkmark.circle.fill")
                        .primaryButton(AppTheme.warningGradient)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                          address.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity((name.trimmingCharacters(in: .whitespaces).isEmpty ||
                          address.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1)
            }
        }
        .navigationTitle(isEditing ? "Muokkaa rataa" : "Uusi ampumarata")
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

        if let range = rangeToEdit {
            // Update existing
            range.name = trimmedName
            range.address = trimmedAddress
            range.latitude = latitude
            range.longitude = longitude
            range.notes = notes.isEmpty ? nil : notes
            range.website = website.isEmpty ? nil : website
            range.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
            range.updatedAt = .now
        } else {
            // Create new
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
        }
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

#Preview("Uusi") {
    NavigationStack {
        RangeFormView()
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Muokkaa") {
    NavigationStack {
        RangeFormView(range: ShootingRange(
            name: "Helsingin Ampumarata",
            address: "Ampumaradantie 1, 00300 Helsinki",
            latitude: 60.1867,
            longitude: 24.9557,
            website: "https://www.ha.fi",
            phoneNumber: "+358 9 123 4567"
        ))
    }
    .modelContainer(PreviewSampleData.container)
}
