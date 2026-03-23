import SwiftUI
import SwiftData
import PhotosUI
import PencilKit
import UniformTypeIdentifiers
import UIKit

struct SessionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Weapon.name) private var weapons: [Weapon]
    @Query(sort: \ShootingRange.name) private var ranges: [ShootingRange]
    @Query(sort: \Instructor.name) private var instructors: [Instructor]

    // Edit mode
    var sessionToEdit: Session?
    private var isEditing: Bool { sessionToEdit != nil }

    // Form state — use value types (PersistentIdentifier) for reliable @State re-renders
    @State private var date = Date.now
    @State private var selectedWeaponID: PersistentIdentifier?
    @State private var selectedRangeID: PersistentIdentifier?
    @State private var numberOfShotsFired: Int = 0
    @State private var type: SessionType = .harjoitus
    @State private var sportType: String = ""
    @State private var role: SessionRole = .ampuja
    @State private var weather: String = ""

    // Optional fields
    @State private var showOptionalFields = false
    @State private var result: String = ""
    @State private var hitFactor: String = ""
    @State private var compScore: String = ""
    @State private var distanceToTarget: String = ""
    @State private var notes: String = ""

    // Instructor
    @State private var selectedInstructorID: PersistentIdentifier?
    @State private var instructorNameInput = ""

    // Signature + media
    @State private var signatureData: Data?
    @State private var showingSignatureCapture = false
    @State private var selectedMediaItems: [PhotosPickerItem] = []
    @State private var photoFileNames: [String] = []
    @State private var videoFileNames: [String] = []
    @State private var importedButUnsavedFileNames: [String] = []
    @State private var isImportingMedia = false

    @State private var errorMessage: String?

    init(session: Session? = nil) {
        self.sessionToEdit = session
        if let session {
            _date = State(initialValue: session.date)
            _selectedWeaponID = State(initialValue: session.weapon?.persistentModelID)
            _selectedRangeID = State(initialValue: session.range?.persistentModelID)
            _numberOfShotsFired = State(initialValue: session.numberOfShotsFired)
            _type = State(initialValue: session.type)
            _sportType = State(initialValue: session.sportType)
            _role = State(initialValue: session.role)
            _weather = State(initialValue: session.weather ?? "")
            _result = State(initialValue: session.result ?? "")
            _hitFactor = State(initialValue: session.hitFactor.map { String($0) } ?? "")
            _compScore = State(initialValue: session.compScore.map { String($0) } ?? "")
            _distanceToTarget = State(initialValue: session.distanceToTarget.map { String(Int($0)) } ?? "")
            _notes = State(initialValue: session.notes ?? "")
            _selectedInstructorID = State(initialValue: session.instructor?.persistentModelID)
            _instructorNameInput = State(initialValue: session.instructorName ?? session.instructor?.name ?? "")
            _signatureData = State(initialValue: session.signature)
            _photoFileNames = State(initialValue: session.photoFileNames)
            _videoFileNames = State(initialValue: session.videoFileNames)
            _showOptionalFields = State(initialValue:
                session.result != nil || session.hitFactor != nil ||
                session.compScore != nil || session.distanceToTarget != nil ||
                (session.notes?.isEmpty == false)
            )
        }
    }

    // Resolve IDs to model objects
    private var selectedWeapon: Weapon? {
        guard let id = selectedWeaponID else { return nil }
        return weapons.first { $0.persistentModelID == id }
    }

    private var selectedRange: ShootingRange? {
        guard let id = selectedRangeID else { return nil }
        return ranges.first { $0.persistentModelID == id }
    }

    private var selectedInstructor: Instructor? {
        guard let id = selectedInstructorID else { return nil }
        return instructors.first { $0.persistentModelID == id }
    }

    /// Available sport types based on selected weapon
    private var availableSportTypes: [String] {
        guard let weapon = selectedWeapon else { return [] }
        return SportTypeMapping.sportTypes(for: weapon.type)
    }

    private var normalizedInstructorName: String {
        instructorNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var requiresInstructorName: Bool {
        signatureData != nil
    }

    var body: some View {
        Form {
            // MARK: - Mandatory Fields
            Section {
                DatePicker("Päivämäärä", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "fi_FI"))

                // Range picker — using Menu for reliable selection
                HStack {
                    Text("Ampumarata")
                    Spacer()
                    Menu {
                        ForEach(ranges) { range in
                            Button {
                                selectedRangeID = range.persistentModelID
                            } label: {
                                if selectedRangeID == range.persistentModelID {
                                    Label(range.name, systemImage: "checkmark")
                                } else {
                                    Text(range.name)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedRange?.name ?? "Valitse rata")
                                .foregroundStyle(selectedRange == nil ? .secondary : .primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Picker("Tyyppi", selection: $type) {
                    ForEach(SessionType.allCases) { sessionType in
                        Text(sessionType.rawValue).tag(sessionType)
                    }
                }

                // Weapon picker — using Menu for reliable selection
                HStack {
                    Text("Ase")
                    Spacer()
                    Menu {
                        ForEach(weapons) { weapon in
                            Button {
                                let changed = selectedWeaponID != weapon.persistentModelID
                                selectedWeaponID = weapon.persistentModelID
                                if changed {
                                    sportType = ""
                                }
                            } label: {
                                if selectedWeaponID == weapon.persistentModelID {
                                    Label("\(weapon.name) (\(weapon.type.rawValue))", systemImage: "checkmark")
                                } else {
                                    Text("\(weapon.name) (\(weapon.type.rawValue))")
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedWeapon.map { "\($0.name) (\($0.type.rawValue))" } ?? "Valitse ase")
                                .foregroundStyle(selectedWeapon == nil ? .secondary : .primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Sport type picker — using Menu
                if !availableSportTypes.isEmpty {
                    HStack {
                        Text("Laji")
                        Spacer()
                        Menu {
                            ForEach(availableSportTypes, id: \.self) { sport in
                                Button {
                                    sportType = sport
                                } label: {
                                    if sportType == sport {
                                        Label(sport, systemImage: "checkmark")
                                    } else {
                                        Text(sport)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(sportType.isEmpty ? "Valitse laji" : sportType)
                                    .foregroundStyle(sportType.isEmpty ? .secondary : .primary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Shot counter: manual entry + quick-add buttons
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Laukauksia")
                        Spacer()
                        TextField("0", value: $numberOfShotsFired, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(Color(hex: "667EEA"))
                            .frame(width: 100)
                    }
                    HStack(spacing: 8) {
                        ForEach([10, 25, 50, 100], id: \.self) { amount in
                            Button("+\(amount)") {
                                withAnimation(.snappy(duration: 0.2)) {
                                    numberOfShotsFired += amount
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "667EEA").opacity(0.1))
                            .foregroundStyle(Color(hex: "667EEA"))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        Spacer()
                        Button("Nollaa") {
                            withAnimation(.snappy(duration: 0.2)) {
                                numberOfShotsFired = 0
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    Text(shotRequirementHelperText)
                        .font(.caption2)
                        .foregroundStyle(shotRequirementHelperColor)
                }

                Picker("Rooli", selection: $role) {
                    ForEach(SessionRole.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }

                TextField("Sää", text: $weather, prompt: Text("esim. Aurinkoinen, +15°C"))
            } header: {
                Label("Pakolliset tiedot", systemImage: "asterisk")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "667EEA"))
            }

            // MARK: - Optional Fields
            Section {
                DisclosureGroup("Valinnaiset kentät", isExpanded: $showOptionalFields) {
                    TextField("Tulos (pisteet/aika)", text: $result)
                    TextField("Hit Factor", text: $hitFactor)
                        .keyboardType(.decimalPad)
                    TextField("Kilpailutulos (%)", text: $compScore)
                        .keyboardType(.decimalPad)
                    TextField("Etäisyys maaliin (m)", text: $distanceToTarget)
                        .keyboardType(.numberPad)
                    TextField("Muistiinpanot", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }

            // MARK: - Instructor
            Section {
                if !instructors.isEmpty {
                    HStack {
                        Text("Valitse tallennettu")
                        Spacer()
                        Menu {
                            Button {
                                selectedInstructorID = nil
                                instructorNameInput = ""
                            } label: {
                                if selectedInstructorID == nil {
                                    Label("Ei valintaa", systemImage: "checkmark")
                                } else {
                                    Text("Ei valintaa")
                                }
                            }

                            Divider()

                            ForEach(instructors) { instructor in
                                Button {
                                    selectedInstructorID = instructor.persistentModelID
                                    instructorNameInput = instructor.name
                                } label: {
                                    if selectedInstructorID == instructor.persistentModelID {
                                        Label(instructor.name, systemImage: "checkmark")
                                    } else {
                                        Text(instructor.name)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedInstructor?.name ?? "Ei valittu")
                                    .foregroundStyle(selectedInstructor == nil ? .secondary : .primary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                TextField("Ohjaajan/valvojan nimi", text: $instructorNameInput, prompt: Text("Kirjoita nimi"))
                    .textInputAutocapitalization(.words)
                    .onChange(of: instructorNameInput) { _, newValue in
                        if let selectedInstructor,
                           selectedInstructor.name != newValue {
                            selectedInstructorID = nil
                        }
                    }

                if requiresInstructorName && normalizedInstructorName.isEmpty {
                    Label("Allekirjoitukselle vaaditaan nimi.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Label("Ohjaaja/valvoja", systemImage: "person.text.rectangle")
            } footer: {
                Text("Valitse olemassa oleva nimi tai kirjoita uusi. Uusi nimi tallennetaan automaattisesti valittavaksi jatkossa.")
            }

            // MARK: - Signature
            Section {
                Button {
                    showingSignatureCapture = true
                } label: {
                    Label(signatureData == nil ? "Lisää allekirjoitus" : "Muokkaa allekirjoitusta",
                          systemImage: "signature")
                }

                if let signatureData,
                   let signatureImage = UIImage(data: signatureData) {
                    Image(uiImage: signatureImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Button(role: .destructive) {
                        self.signatureData = nil
                    } label: {
                        Label("Poista allekirjoitus", systemImage: "trash")
                    }
                }
            } header: {
                Label("Allekirjoitus", systemImage: "signature")
            } footer: {
                Text("Avaus siirtää näkymän vaakatilaan, jotta valmentaja voi allekirjoittaa sormella.")
            }

            // MARK: - Media
            Section {
                PhotosPicker(
                    selection: $selectedMediaItems,
                    maxSelectionCount: 20,
                    matching: .any(of: [.images, .videos]),
                    photoLibrary: .shared()
                ) {
                    Label("Lisää kuvia tai videoita", systemImage: "photo.on.rectangle.angled")
                }

                if isImportingMedia {
                    ProgressView("Tuodaan mediaa…")
                }

                if !photoFileNames.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kuvat")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(photoFileNames, id: \.self) { fileName in
                                    SessionPhotoChip(
                                        image: photoImage(for: fileName),
                                        onDelete: { removePhoto(fileName) }
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if !videoFileNames.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Videot")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(Array(videoFileNames.enumerated()), id: \.element) { index, fileName in
                            HStack {
                                Label("Video \(index + 1)", systemImage: "video.fill")
                                    .lineLimit(1)
                                Spacer()
                                Button(role: .destructive) {
                                    removeVideo(fileName)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            } header: {
                Label("Media", systemImage: "photo.stack")
            }

            // MARK: - Error
            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            // MARK: - Submit
            Section {
                Button {
                    saveSession()
                } label: {
                    Label(isEditing ? "Tallenna muutokset" : "Kirjaa suoritus",
                          systemImage: "checkmark.circle.fill")
                        .primaryButton(AppTheme.successGradient)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.5)
            }
        }
        .navigationTitle(isEditing ? "Muokkaa harjoitetta" : "Uusi harjoite")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") {
                    cancelForm()
                }
            }
        }
        .fullScreenCover(isPresented: $showingSignatureCapture) {
            SignatureCaptureView(signatureData: $signatureData)
        }
        .onChange(of: selectedMediaItems) { _, newItems in
            Task { await importMediaItems(newItems) }
        }
    }

    private var minimumShotsRequired: Int {
        // 0 shots is valid when user is in a non-shooter role
        // or when logging dry-fire practice.
        (role != .ampuja || type == .kuivaharjoittelu) ? 0 : 1
    }

    private var shotRequirementHelperText: String {
        if minimumShotsRequired == 0 {
            return "0 laukausta on sallittu tässä valinnassa (esim. muu rooli tai kuivaharjoittelu)."
        }
        return "Kirjaa vähintään 1 laukaus tässä valinnassa."
    }

    private var shotRequirementHelperColor: Color {
        minimumShotsRequired == 0 ? .secondary : .orange
    }

    private var isFormValid: Bool {
        selectedWeapon != nil &&
        selectedRange != nil &&
        !sportType.isEmpty &&
        numberOfShotsFired >= minimumShotsRequired &&
        (!requiresInstructorName || !normalizedInstructorName.isEmpty)
    }

    private func photoImage(for fileName: String) -> UIImage? {
        let url = SessionMediaStorage.url(for: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func removePhoto(_ fileName: String) {
        photoFileNames.removeAll { $0 == fileName }
        cleanupUnsavedImportedFileIfNeeded(fileName)
    }

    private func removeVideo(_ fileName: String) {
        videoFileNames.removeAll { $0 == fileName }
        cleanupUnsavedImportedFileIfNeeded(fileName)
    }

    private func cleanupUnsavedImportedFileIfNeeded(_ fileName: String) {
        if importedButUnsavedFileNames.contains(fileName) {
            SessionMediaStorage.deleteMedia(named: fileName)
            importedButUnsavedFileNames.removeAll { $0 == fileName }
        }
    }

    @MainActor
    private func importMediaItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        isImportingMedia = true
        defer {
            isImportingMedia = false
            selectedMediaItems = []
        }

        for item in items {
            do {
                let isVideo = item.supportedContentTypes.contains { type in
                    type.conforms(to: .movie) || type.conforms(to: .video)
                }

                if isVideo, let sourceURL = try await item.loadTransferable(type: URL.self) {
                    let fileName = try SessionMediaStorage.saveVideoCopy(from: sourceURL)
                    videoFileNames.append(fileName)
                    importedButUnsavedFileNames.append(fileName)
                    continue
                }

                if let data = try await item.loadTransferable(type: Data.self) {
                    if isVideo {
                        let tempExt = item.supportedContentTypes.first?.preferredFilenameExtension ?? "mov"
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent("\(UUID().uuidString).\(tempExt)")
                        try data.write(to: tempURL, options: .atomic)
                        defer { try? FileManager.default.removeItem(at: tempURL) }

                        let fileName = try SessionMediaStorage.saveVideoCopy(from: tempURL)
                        videoFileNames.append(fileName)
                        importedButUnsavedFileNames.append(fileName)
                    } else {
                        let fileName = try SessionMediaStorage.saveImageData(data)
                        photoFileNames.append(fileName)
                        importedButUnsavedFileNames.append(fileName)
                    }
                }
            } catch {
                errorMessage = "Median tuonti epäonnistui. Yritä uudelleen."
            }
        }
    }

    private func parseOptionalDouble(_ rawValue: String) -> Double? {
        let normalized = rawValue
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        return Double(normalized)
    }

    private func resolveInstructorForSave() -> Instructor? {
        let name = normalizedInstructorName
        guard !name.isEmpty else { return nil }

        if let selectedInstructor,
           selectedInstructor.name.compare(name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame {
            return selectedInstructor
        }

        if let existing = instructors.first(where: {
            $0.name.compare(name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) {
            return existing
        }

        let newInstructor = Instructor(name: name)
        modelContext.insert(newInstructor)
        return newInstructor
    }

    private func saveSession() {
        guard let weapon = selectedWeapon,
              let range = selectedRange,
              !sportType.isEmpty,
              numberOfShotsFired >= minimumShotsRequired,
              (!requiresInstructorName || !normalizedInstructorName.isEmpty) else {
            if requiresInstructorName && normalizedInstructorName.isEmpty {
                errorMessage = "Lisää ohjaajan/valvojan nimi allekirjoitukselle."
            } else {
                errorMessage = minimumShotsRequired == 0
                    ? "Täytä kaikki pakolliset kentät."
                    : "Täytä kaikki pakolliset kentät. Laukauksia pitää olla vähintään 1."
            }
            return
        }

        let resolvedInstructor = resolveInstructorForSave()
        let resolvedInstructorName = normalizedInstructorName.isEmpty ? nil : normalizedInstructorName

        if let session = sessionToEdit {
            // Delete files removed during edit
            let removedPhotos = Set(session.photoFileNames).subtracting(photoFileNames)
            let removedVideos = Set(session.videoFileNames).subtracting(videoFileNames)
            SessionMediaStorage.deleteMedia(named: Array(removedPhotos) + Array(removedVideos))

            // Update existing
            session.date = date
            session.numberOfShotsFired = numberOfShotsFired
            session.type = type
            session.sportType = sportType
            session.role = role
            session.weather = weather.isEmpty ? nil : weather
            session.result = result.isEmpty ? nil : result
            session.hitFactor = parseOptionalDouble(hitFactor)
            session.compScore = parseOptionalDouble(compScore)
            session.distanceToTarget = parseOptionalDouble(distanceToTarget)
            session.notes = notes.isEmpty ? nil : notes
            session.signature = signatureData
            session.instructorName = resolvedInstructorName
            session.instructor = resolvedInstructor
            session.photoFileNames = photoFileNames
            session.videoFileNames = videoFileNames
            session.weapon = weapon
            session.range = range
            session.updatedAt = .now
        } else {
            // Create new
            let session = Session(
                date: date,
                numberOfShotsFired: numberOfShotsFired,
                type: type,
                sportType: sportType,
                role: role,
                weather: weather.isEmpty ? nil : weather,
                result: result.isEmpty ? nil : result,
                hitFactor: parseOptionalDouble(hitFactor),
                compScore: parseOptionalDouble(compScore),
                distanceToTarget: parseOptionalDouble(distanceToTarget),
                notes: notes.isEmpty ? nil : notes,
                signature: signatureData,
                instructorName: resolvedInstructorName,
                weapon: weapon,
                range: range,
                instructor: resolvedInstructor
            )
            session.photoFileNames = photoFileNames
            session.videoFileNames = videoFileNames
            modelContext.insert(session)
        }

        importedButUnsavedFileNames.removeAll()
        dismiss()
    }

    private func cancelForm() {
        SessionMediaStorage.deleteMedia(named: importedButUnsavedFileNames)
        importedButUnsavedFileNames.removeAll()
        dismiss()
    }
}

// MARK: - Media Chips

private struct SessionPhotoChip: View {
    let image: UIImage?
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 110, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white, .red)
            }
            .padding(4)
        }
    }
}

// MARK: - Signature Capture

private struct SignatureCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var signatureData: Data?

    @State private var drawing = PKDrawing()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("Peruuta") {
                        setPortraitOrientation()
                        dismiss()
                    }

                    Spacer()

                    Button("Tyhjennä") {
                        drawing = PKDrawing()
                    }

                    Button("Tallenna") {
                        if drawing.strokes.isEmpty {
                            signatureData = nil
                        } else {
                            let bounds = drawing.bounds.insetBy(dx: -20, dy: -20)
                            let exportRect = bounds.isNull || bounds.isEmpty
                                ? CGRect(x: 0, y: 0, width: 1400, height: 700)
                                : bounds
                            let image = drawing.image(from: exportRect, scale: UIScreen.main.scale)
                            signatureData = image.pngData()
                        }
                        setPortraitOrientation()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                .padding()

                SignatureCanvasView(drawing: $drawing)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding()
            }
        }
        .onAppear {
            setLandscapeOrientation()
        }
    }

    private func setLandscapeOrientation() {
        updateOrientation(.landscape)
    }

    private func setPortraitOrientation() {
        updateOrientation(.portrait)
    }

    private func updateOrientation(_ orientation: UIInterfaceOrientationMask) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { _ in }
        scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}

private struct SignatureCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .white
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvas.alwaysBounceVertical = false
        canvas.alwaysBounceHorizontal = false
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

#Preview("Uusi") {
    NavigationStack {
        SessionFormView()
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Muokkaa") {
    NavigationStack {
        SessionFormView(session: Session(
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
    .modelContainer(PreviewSampleData.container)
}
