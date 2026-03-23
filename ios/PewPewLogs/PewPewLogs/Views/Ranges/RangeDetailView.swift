import SwiftUI
import MapKit

struct RangeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let range: ShootingRange

    @State private var showingEditSheet = false
    @State private var showDeleteConfirmation = false

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: range.latitude, longitude: range.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Hero Map
                heroMap

                VStack(spacing: 16) {
                    infoCard
                    contactCard
                    if !range.sessions.isEmpty {
                        usageCard
                    }
                    metadataCard
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(range.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Muokkaa", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Poista", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                RangeFormView(range: range)
            }
        }
        .alert("Poista ampumarata?", isPresented: $showDeleteConfirmation) {
            Button("Poista", role: .destructive) {
                modelContext.delete(range)
                dismiss()
            }
            Button("Peruuta", role: .cancel) {}
        } message: {
            if range.sessions.isEmpty {
                Text("Haluatko varmasti poistaa ampumaradan \"\(range.name)\"? Tätä ei voi perua.")
            } else {
                Text("Haluatko varmasti poistaa ampumaradan \"\(range.name)\"? Rata on käytössä \(range.sessions.count) harjoitteessa. Tätä ei voi perua.")
            }
        }
    }

    // MARK: - Hero Map

    private var heroMap: some View {
        ZStack(alignment: .bottom) {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))) {
                Marker(range.name, coordinate: coordinate)
                    .tint(Color(hex: "F2994A"))
            }
            .frame(height: 280)

            // Overlay gradient
            LinearGradient(
                colors: [.clear, Color(.systemGroupedBackground).opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)

            // Name overlay
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(range.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(range.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Tiedot", icon: "info.circle.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Nimi", value: range.name, icon: "textformat")
                Divider().padding(.leading, 44)
                DetailRow(label: "Osoite", value: range.address, icon: "mappin.circle.fill")
                Divider().padding(.leading, 44)
                DetailRow(
                    label: "Koordinaatit",
                    value: String(format: "%.6f, %.6f", range.latitude, range.longitude),
                    icon: "location.circle.fill"
                )
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Contact Card

    private var contactCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Yhteystiedot", icon: "phone.circle.fill")

            VStack(spacing: 0) {
                if let website = range.website, !website.isEmpty,
                   let url = URL(string: website.hasPrefix("http") ? website : "https://\(website)") {
                    Link(destination: url) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "667EEA"))
                                .frame(width: 24)
                            Text("Verkkosivusto")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(website)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "667EEA"))
                                .lineLimit(1)
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                                .foregroundStyle(Color(hex: "667EEA"))
                        }
                        .padding(14)
                    }
                }

                if let phone = range.phoneNumber, !phone.isEmpty,
                   let url = URL(string: "tel:\(phone)") {
                    if range.website != nil && !range.website!.isEmpty {
                        Divider().padding(.leading, 44)
                    }
                    Link(destination: url) {
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "11998E"))
                                .frame(width: 24)
                            Text("Puhelin")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(phone)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "11998E"))
                            Image(systemName: "phone.arrow.up.right")
                                .font(.caption2)
                                .foregroundStyle(Color(hex: "11998E"))
                        }
                        .padding(14)
                    }
                }

                if let notes = range.notes, !notes.isEmpty {
                    Divider().padding(.leading, 44)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "note.text")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text("Muistiinpanot")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(notes)
                            .font(.subheadline)
                            .padding(.leading, 34)
                    }
                    .padding(14)
                }

                if (range.website == nil || range.website?.isEmpty == true) &&
                   (range.phoneNumber == nil || range.phoneNumber?.isEmpty == true) &&
                   (range.notes == nil || range.notes?.isEmpty == true) {
                    HStack {
                        Text("Ei yhteystietoja")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Usage Card

    private var usageCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Käyttöhistoria", icon: "chart.bar.fill")

            HStack(spacing: 0) {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(range.sessions.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    Text("Harjoitetta")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 50)

                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "burst.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "667EEA"))
                        Text("\(range.sessions.reduce(0) { $0 + $1.numberOfShotsFired })")
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    Text("Laukausta")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Metadata

    private var metadataCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Tiedot", icon: "clock.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Luotu", value: DateFormatters.shortDate.string(from: range.createdAt), icon: "plus.circle")
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
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
