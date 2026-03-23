import SwiftUI
import SwiftData
import UIKit
import AVFoundation

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @Query(sort: \Instructor.name) private var instructors: [Instructor]
    @State private var searchText = ""
    @State private var showingNewSession = false
    @State private var sessionToEdit: Session?
    @State private var sessionToDelete: Session?
    @State private var showDeleteConfirmation = false
    @State private var exportedPDFURL: URL?
    @State private var showShareSheet = false
    @State private var showExportError = false
    @State private var exportErrorMessage = ""

    // PDF filters
    @State private var showExportOptions = false
    @State private var exportUseDateRange = false
    @State private var exportFromDate = Calendar.current.date(byAdding: .month, value: -12, to: .now) ?? .now
    @State private var exportToDate = Date.now
    @State private var exportWeaponID: PersistentIdentifier?
    @State private var exportInstructorID: PersistentIdentifier?

    var filteredSessions: [Session] {
        if searchText.isEmpty { return sessions }
        return sessions.filter { session in
            session.sportType.localizedCaseInsensitiveContains(searchText) ||
            session.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
            session.weapon?.name.localizedCaseInsensitiveContains(searchText) == true ||
            session.range?.name.localizedCaseInsensitiveContains(searchText) == true ||
            session.instructorName?.localizedCaseInsensitiveContains(searchText) == true ||
            session.instructor?.name.localizedCaseInsensitiveContains(searchText) == true
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
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showExportOptions = true
                } label: {
                    Label("Vie PDF", systemImage: "square.and.arrow.up")
                }
                .disabled(sessions.isEmpty)
            }

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
        .sheet(isPresented: $showExportOptions) {
            NavigationStack {
                exportOptionsView
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Poista harjoite?", isPresented: $showDeleteConfirmation, presenting: sessionToDelete) { session in
            Button("Poista", role: .destructive) {
                withAnimation {
                    SessionMediaStorage.deleteMedia(named: session.photoFileNames + session.videoFileNames)
                    modelContext.delete(session)
                }
            }
            Button("Peruuta", role: .cancel) {
                sessionToDelete = nil
            }
        } message: { session in
            Text("Haluatko varmasti poistaa harjoitteen (\(DateFormatters.shortDate.string(from: session.date)), \(session.sportType))? Tätä ei voi perua.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let exportedPDFURL {
                ActivityViewController(activityItems: [exportedPDFURL])
            }
        }
        .alert("PDF-vienti epäonnistui", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage)
        }
    }

    // MARK: - PDF Export

    private var selectedExportInstructor: Instructor? {
        guard let exportInstructorID else { return nil }
        return instructors.first { $0.persistentModelID == exportInstructorID }
    }

    private var selectedExportWeapon: Weapon? {
        guard let exportWeaponID else { return nil }
        return weapons.first { $0.persistentModelID == exportWeaponID }
    }

    private var filteredSessionsForExport: [Session] {
        var result = sessions

        if exportUseDateRange {
            let calendar = Calendar.current
            let lowerDate = min(exportFromDate, exportToDate)
            let upperDate = max(exportFromDate, exportToDate)
            let from = calendar.startOfDay(for: lowerDate)
            let toDayStart = calendar.startOfDay(for: upperDate)
            let toExclusive = calendar.date(byAdding: .day, value: 1, to: toDayStart) ?? toDayStart
            result = result.filter { $0.date >= from && $0.date < toExclusive }
        }

        if let exportWeaponID {
            result = result.filter { $0.weapon?.persistentModelID == exportWeaponID }
        }

        if let exportInstructorID {
            let instructorName = selectedExportInstructor?.name
            result = result.filter { session in
                if session.instructor?.persistentModelID == exportInstructorID {
                    return true
                }
                guard let instructorName,
                      let sessionInstructorName = session.instructorName else { return false }
                return sessionInstructorName.compare(instructorName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }
        }

        return result.sorted { $0.date > $1.date }
    }

    private var exportFilterSummaryLines: [String] {
        var lines: [String] = []

        if exportUseDateRange {
            let lowerDate = min(exportFromDate, exportToDate)
            let upperDate = max(exportFromDate, exportToDate)
            lines.append("Ajanjakso: \(DateFormatters.shortDate.string(from: lowerDate)) - \(DateFormatters.shortDate.string(from: upperDate))")
        }

        if let selectedExportWeapon {
            lines.append("Ase: \(selectedExportWeapon.name)")
        }

        if let selectedExportInstructor {
            lines.append("Ohjaaja/valvoja: \(selectedExportInstructor.name)")
        }

        if lines.isEmpty {
            lines.append("Suodatus: Kaikki merkinnät")
        }

        return lines
    }

    private var exportOptionsView: some View {
        Form {
            Section("Ajanjakso") {
                Toggle("Rajaa ajanjakso", isOn: $exportUseDateRange)
                if exportUseDateRange {
                    DatePicker("Alkaen", selection: $exportFromDate, displayedComponents: .date)
                    DatePicker("Asti", selection: $exportToDate, displayedComponents: .date)
                }
            }

            Section("Ase") {
                Picker("Ase", selection: $exportWeaponID) {
                    Text("Kaikki aseet").tag(Optional<PersistentIdentifier>.none)
                    ForEach(weapons) { weapon in
                        Text(weapon.name).tag(Optional(weapon.persistentModelID))
                    }
                }
            }

            Section("Ohjaaja/valvoja") {
                Picker("Nimi", selection: $exportInstructorID) {
                    Text("Kaikki nimet").tag(Optional<PersistentIdentifier>.none)
                    ForEach(instructors) { instructor in
                        Text(instructor.name).tag(Optional(instructor.persistentModelID))
                    }
                }
            }

            Section {
                Button {
                    exportDiaryAsPDF()
                    showExportOptions = false
                } label: {
                    Label("Luo PDF", systemImage: "doc.richtext")
                        .primaryButton(AppTheme.primaryGradient)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if !filteredSessionsForExport.isEmpty {
                Section {
                    Text("Valinnoilla mukaan tulee \(filteredSessionsForExport.count) merkintää.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("PDF-vienti")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Sulje") { showExportOptions = false }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nollaa") {
                    exportUseDateRange = false
                    exportFromDate = Calendar.current.date(byAdding: .month, value: -12, to: .now) ?? .now
                    exportToDate = .now
                    exportWeaponID = nil
                    exportInstructorID = nil
                }
            }
        }
    }

    private func exportDiaryAsPDF() {
        do {
            guard !filteredSessionsForExport.isEmpty else {
                exportErrorMessage = "Ei merkintöjä valituilla suodattimilla."
                showExportError = true
                return
            }

            let url = try generateDiaryPDF(
                from: filteredSessionsForExport,
                filterSummary: exportFilterSummaryLines
            )
            exportedPDFURL = url
            showShareSheet = true
        } catch {
            exportErrorMessage = "PDF:n luonti epäonnistui. Yritä uudelleen."
            showExportError = true
        }
    }

    private func generateDiaryPDF(from sessions: [Session], filterSummary: [String]) throws -> URL {
        let fileName = "Ratadata-paivakirja-\(ISO8601DateFormatter().string(from: Date())).pdf"
            .replacingOccurrences(of: ":", with: "-")
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let pageRect = CGRect(x: 0, y: 0, width: 842, height: 595) // A4 landscape
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: outputURL) { context in
            let margin: CGFloat = 24
            let rowHeight: CGFloat = 64
            let contentWidth = pageRect.width - margin * 2

            let dateWidth: CGFloat = 90
            let typeWidth: CGFloat = 120
            let weaponWidth: CGFloat = 160
            let shotsWidth: CGFloat = 70
            let instructorWidth: CGFloat = 170
            let signatureWidth: CGFloat = contentWidth - dateWidth - typeWidth - weaponWidth - shotsWidth - instructorWidth

            let columns: [(title: String, width: CGFloat)] = [
                ("Pvm", dateWidth),
                ("Tyyppi", typeWidth),
                ("Ase", weaponWidth),
                ("Lauk.", shotsWidth),
                ("Ohjaaja/valvoja", instructorWidth),
                ("Allekirjoitus", signatureWidth)
            ]

            let logo = UIImage(named: "RatadataIcon")

            var y: CGFloat = margin
            var pageNumber = 1

            func drawPageHeader() {
                let logoSize: CGFloat = 40
                if let logo {
                    logo.draw(in: CGRect(x: margin, y: y, width: logoSize, height: logoSize))
                }

                let titleX = margin + (logo == nil ? 0 : logoSize + 10)

                let title = "Ratadata Ampumapäiväkirja"
                let subtitle = "Virallinen yhteenveto lupahakemusta varten"
                let generated = "Luotu: \(DateFormatters.shortDate.string(from: .now))"
                let total = "Merkintöjä: \(sessions.count)"
                let signatureStamp = "Allekirjoituskuvat tallennettu sähköisesti Ratadata-sovelluksella"

                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
                let subtitleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.darkGray
                ]
                let metaAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]
                let stampAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]

                title.draw(at: CGPoint(x: titleX, y: y), withAttributes: titleAttrs)
                subtitle.draw(at: CGPoint(x: titleX, y: y + 24), withAttributes: subtitleAttrs)
                generated.draw(at: CGPoint(x: titleX, y: y + 40), withAttributes: metaAttrs)
                total.draw(at: CGPoint(x: titleX + 160, y: y + 40), withAttributes: metaAttrs)

                if let firstFilter = filterSummary.first {
                    firstFilter.draw(at: CGPoint(x: titleX, y: y + 54), withAttributes: metaAttrs)
                }
                if filterSummary.count > 1 {
                    let secondLine = filterSummary.dropFirst().joined(separator: " · ")
                    secondLine.draw(at: CGPoint(x: titleX, y: y + 68), withAttributes: metaAttrs)
                }

                let pageText = "Sivu \(pageNumber)"
                let pageSize = pageText.size(withAttributes: metaAttrs)
                pageText.draw(
                    at: CGPoint(x: pageRect.width - margin - pageSize.width, y: y + 40),
                    withAttributes: metaAttrs
                )

                let stampWidth = (signatureStamp as NSString).size(withAttributes: stampAttrs).width
                (signatureStamp as NSString).draw(
                    at: CGPoint(x: pageRect.width - margin - stampWidth, y: y + 54),
                    withAttributes: stampAttrs
                )

                y += 94

                let headerRect = CGRect(x: margin, y: y, width: contentWidth, height: 30)
                UIColor.systemBlue.setFill()
                context.cgContext.fill(headerRect)

                var x = margin
                for column in columns {
                    let rect = CGRect(x: x, y: y, width: column.width, height: 30)
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                        .foregroundColor: UIColor.white
                    ]
                    let textRect = rect.insetBy(dx: 6, dy: 8)
                    (column.title as NSString).draw(in: textRect, withAttributes: attrs)

                    context.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
                    context.cgContext.stroke(CGRect(x: rect.maxX, y: rect.minY, width: 0.5, height: rect.height))
                    x += column.width
                }

                y += 30
            }

            func drawRow(_ session: Session, rowIndex: Int) {
                let rowRect = CGRect(x: margin, y: y, width: contentWidth, height: rowHeight)
                let isEven = rowIndex % 2 == 0
                (isEven ? UIColor.systemGray6 : UIColor.white).setFill()
                context.cgContext.fill(rowRect)

                context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.stroke(rowRect)

                let values: [String] = [
                    DateFormatters.shortDate.string(from: session.date),
                    session.type.rawValue,
                    session.weapon?.name ?? "-",
                    "\(session.numberOfShotsFired)",
                    session.instructorName ?? session.instructor?.name ?? "-",
                    ""
                ]

                var x = margin
                for (idx, column) in columns.enumerated() {
                    let cellRect = CGRect(x: x, y: y, width: column.width, height: rowHeight)

                    if idx == columns.count - 1 {
                        if let signatureData = session.signature,
                           let image = UIImage(data: signatureData) {
                            let imageArea = cellRect.insetBy(dx: 6, dy: 6)
                            let signatureArea = CGRect(
                                x: imageArea.minX,
                                y: imageArea.minY,
                                width: imageArea.width,
                                height: max(24, imageArea.height - 12)
                            )
                            let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: signatureArea)
                            image.draw(in: imageRect)

                            let stampAttrs: [NSAttributedString.Key: Any] = [
                                .font: UIFont.systemFont(ofSize: 7),
                                .foregroundColor: UIColor.secondaryLabel
                            ]
                            ("Ratadata sähköinen allekirjoitus" as NSString).draw(
                                in: CGRect(
                                    x: cellRect.minX + 6,
                                    y: cellRect.maxY - 11,
                                    width: cellRect.width - 12,
                                    height: 8
                                ),
                                withAttributes: stampAttrs
                            )
                        } else {
                            let attrs: [NSAttributedString.Key: Any] = [
                                .font: UIFont.systemFont(ofSize: 10),
                                .foregroundColor: UIColor.secondaryLabel
                            ]
                            ("-" as NSString).draw(in: cellRect.insetBy(dx: 6, dy: 24), withAttributes: attrs)
                        }
                    } else {
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 11),
                            .foregroundColor: UIColor.label
                        ]
                        (values[idx] as NSString).draw(
                            in: cellRect.insetBy(dx: 6, dy: 10),
                            withAttributes: attrs
                        )
                    }

                    context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
                    context.cgContext.stroke(CGRect(x: cellRect.maxX, y: cellRect.minY, width: 0.5, height: cellRect.height))
                    x += column.width
                }

                y += rowHeight
            }

            context.beginPage()
            drawPageHeader()

            for (index, session) in sessions.enumerated() {
                if y + rowHeight > pageRect.height - margin {
                    pageNumber += 1
                    context.beginPage()
                    y = margin
                    drawPageHeader()
                }
                drawRow(session, rowIndex: index)
            }
        }

        return outputURL
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
        case .harjoitus: "target"
        case .harjoituskilpailu: "flag.fill"
        case .kuivaharjoittelu: "scope"
        case .seuranViikkokisa: "person.3.fill"
        case .valmennus: "graduationcap.fill"
        case .muuMerkinta: "note.text"
        }
    }
}

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SessionListView()
    }
    .modelContainer(PreviewSampleData.container)
}
