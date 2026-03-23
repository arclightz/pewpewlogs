import SwiftUI
import AVKit
import UIKit

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: Session

    @State private var showingEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Hero Header
                heroHeader

                // MARK: - Info Cards
                VStack(spacing: 16) {
                    basicInfoCard
                    weaponRangeCard
                    if hasOptionalData {
                        optionalInfoCard
                    }
                    if let signatureImage = signatureImage {
                        signatureCard(signatureImage)
                    }
                    if hasMedia {
                        mediaCard
                    }
                    metadataCard
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Harjoite")
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
                SessionFormView(session: session)
            }
        }
        .alert("Poista harjoite?", isPresented: $showDeleteConfirmation) {
            Button("Poista", role: .destructive) {
                SessionMediaStorage.deleteMedia(named: session.photoFileNames + session.videoFileNames)
                modelContext.delete(session)
                dismiss()
            }
            Button("Peruuta", role: .cancel) {}
        } message: {
            Text("Haluatko varmasti poistaa tämän harjoitteen (\(DateFormatters.shortDate.string(from: session.date)))? Tätä ei voi perua.")
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: sessionTypeIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text(session.sportType)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(session.date, format: .dateTime.day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("\(session.numberOfShotsFired)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Laukausta")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    Text(session.type.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Tyyppi")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    Text(session.role.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Rooli")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal)
        .background(AppTheme.sessionTypeGradient(session.type))
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // MARK: - Basic Info Card

    private var basicInfoCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Perustiedot", icon: "info.circle.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Päivämäärä", value: DateFormatters.longDate.string(from: session.date), icon: "calendar")
                Divider().padding(.leading, 44)
                DetailRow(label: "Tyyppi", value: session.type.rawValue, icon: "tag.fill")
                Divider().padding(.leading, 44)
                DetailRow(label: "Laji", value: session.sportType, icon: "target")
                Divider().padding(.leading, 44)
                DetailRow(label: "Rooli", value: session.role.rawValue, icon: "person.fill")
                Divider().padding(.leading, 44)
                DetailRow(label: "Laukauksia", value: "\(session.numberOfShotsFired)", icon: "flame.fill")
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Weapon & Range Card

    private var weaponRangeCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Ase ja rata", icon: "scope")

            VStack(spacing: 0) {
                if let weapon = session.weapon {
                    DetailRow(label: "Ase", value: "\(weapon.name) (\(weapon.type.rawValue))", icon: "scope")
                    if session.range != nil {
                        Divider().padding(.leading, 44)
                    }
                }
                if let range = session.range {
                    DetailRow(label: "Ampumarata", value: range.name, icon: "mappin.circle.fill")
                }
                if let instructorDisplayName {
                    if session.weapon != nil || session.range != nil {
                        Divider().padding(.leading, 44)
                    }
                    DetailRow(label: "Ohjaaja/valvoja", value: instructorDisplayName, icon: "person.text.rectangle")
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Optional Info Card

    private var optionalInfoCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Lisätiedot", icon: "ellipsis.circle.fill")

            VStack(spacing: 0) {
                if let weather = session.weather, !weather.isEmpty {
                    DetailRow(label: "Sää", value: weather, icon: "cloud.sun.fill")
                    Divider().padding(.leading, 44)
                }
                if let result = session.result, !result.isEmpty {
                    DetailRow(label: "Tulos", value: result, icon: "chart.bar.fill")
                    Divider().padding(.leading, 44)
                }
                if let hf = session.hitFactor {
                    DetailRow(label: "Hit Factor", value: String(format: "%.2f", hf), icon: "bolt.fill")
                    Divider().padding(.leading, 44)
                }
                if let cs = session.compScore {
                    DetailRow(label: "Kilpailutulos", value: String(format: "%.1f%%", cs), icon: "trophy.fill")
                    Divider().padding(.leading, 44)
                }
                if let dist = session.distanceToTarget {
                    DetailRow(label: "Etäisyys", value: "\(Int(dist)) m", icon: "ruler.fill")
                    Divider().padding(.leading, 44)
                }
                if let notes = session.notes, !notes.isEmpty {
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
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Signature Card

    private var signatureImage: UIImage? {
        guard let signatureData = session.signature else { return nil }
        return UIImage(data: signatureData)
    }

    private var instructorDisplayName: String? {
        if let name = session.instructorName, !name.isEmpty { return name }
        if let name = session.instructor?.name, !name.isEmpty { return name }
        return nil
    }

    private func signatureCard(_ image: UIImage) -> some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Allekirjoitus", icon: "signature")

            VStack(alignment: .leading, spacing: 8) {
                if let instructorDisplayName {
                    HStack(spacing: 8) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundStyle(.secondary)
                        Text(instructorDisplayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .frame(maxWidth: .infinity)
                    .padding(12)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Media Card

    private var hasMedia: Bool {
        !session.photoFileNames.isEmpty || !session.videoFileNames.isEmpty
    }

    private var mediaCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Media", icon: "photo.stack")

            VStack(alignment: .leading, spacing: 12) {
                if !session.photoFileNames.isEmpty {
                    Text("Kuvat")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(session.photoFileNames, id: \.self) { fileName in
                                if let image = photoImage(for: fileName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if !session.videoFileNames.isEmpty {
                    Text("Videot")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(Array(session.videoFileNames.enumerated()), id: \.element) { index, fileName in
                        NavigationLink {
                            SessionVideoPlayerView(videoURL: SessionMediaStorage.url(for: fileName))
                        } label: {
                            HStack {
                                Label("Video \(index + 1)", systemImage: "video.fill")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(Color(hex: "667EEA"))
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    private func photoImage(for fileName: String) -> UIImage? {
        let url = SessionMediaStorage.url(for: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Metadata Card

    private var metadataCard: some View {
        VStack(spacing: 0) {
            DetailSectionHeader(title: "Tiedot", icon: "clock.fill")

            VStack(spacing: 0) {
                DetailRow(label: "Luotu", value: DateFormatters.shortDate.string(from: session.createdAt), icon: "plus.circle")
                Divider().padding(.leading, 44)
                DetailRow(label: "Päivitetty", value: DateFormatters.shortDate.string(from: session.updatedAt), icon: "pencil.circle")
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Helpers

    private var hasOptionalData: Bool {
        session.weather != nil || session.result != nil ||
        session.hitFactor != nil || session.compScore != nil ||
        session.distanceToTarget != nil || session.notes != nil
    }

    private var sessionTypeIcon: String {
        switch session.type {
        case .kilpailu: "trophy.fill"
        case .harjoitus: "target"
        case .harjoituskilpailu: "flag.fill"
        case .kuivaharjoittelu: "scope"
        case .seuranViikkokisa: "person.3.fill"
        case .valmennus: "graduationcap.fill"
        case .muuMerkinta: "note.text"
        }
    }
}

private struct SessionVideoPlayerView: View {
    let videoURL: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .navigationTitle("Video")
            .navigationBarTitleDisplayMode(.inline)
            .background(.black)
            .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Detail Section Header

struct DetailSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemFill).opacity(0.5))
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(14)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: Session(
            date: .now,
            numberOfShotsFired: 150,
            type: .harjoitus,
            sportType: "IPSC",
            role: .ampuja,
            weather: "Aurinkoinen, +18°C",
            result: "87%",
            hitFactor: 5.23,
            notes: "Hyvä harjoitus"
        ))
    }
}
