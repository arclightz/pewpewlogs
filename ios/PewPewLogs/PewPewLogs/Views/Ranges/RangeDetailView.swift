import SwiftUI
import MapKit

struct RangeDetailView: View {
    let range: ShootingRange

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: range.latitude, longitude: range.longitude)
    }

    var body: some View {
        List {
            // MARK: - Map
            Section {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(range.name, coordinate: coordinate)
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listRowInsets(EdgeInsets())
            }

            // MARK: - Info
            Section("Tiedot") {
                LabeledContent("Nimi", value: range.name)
                LabeledContent("Osoite", value: range.address)
                LabeledContent("Koordinaatit", value: String(
                    format: "%.6f, %.6f", range.latitude, range.longitude
                ))
            }

            // MARK: - Contact
            Section("Yhteystiedot") {
                if let website = range.website, !website.isEmpty {
                    if let url = URL(string: website) {
                        Link(destination: url) {
                            LabeledContent("Verkkosivusto") {
                                Text(website)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                if let phone = range.phoneNumber, !phone.isEmpty {
                    if let url = URL(string: "tel:\(phone)") {
                        Link(destination: url) {
                            LabeledContent("Puhelin") {
                                Text(phone)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                if let notes = range.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Muistiinpanot")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(notes)
                    }
                }
            }

            // MARK: - Usage
            if !range.sessions.isEmpty {
                Section("Käyttöhistoria") {
                    LabeledContent("Harjoitteita", value: "\(range.sessions.count)")
                }
            }

            Section("Tiedot") {
                LabeledContent("Luotu", value: range.createdAt, format: .dateTime)
            }
        }
        .navigationTitle(range.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RangeDetailView(range: ShootingRange(
            name: "Helsingin Ampumarata",
            address: "Ampumaradantie 1, 00300 Helsinki",
            latitude: 60.1867,
            longitude: 24.9557,
            website: "https://www.ha.fi",
            phoneNumber: "+358 9 123 4567"
        ))
    }
}
