import Foundation
import SwiftData
import UniformTypeIdentifiers

@Model
final class Instructor {
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Session.instructor)
    var sessions: [Session] = []

    init(name: String) {
        self.name = name
        self.createdAt = .now
    }
}

@Model
final class Session {
    // MARK: - Mandatory fields
    var date: Date
    var numberOfShotsFired: Int
    var type: SessionType
    var sportType: String
    var role: SessionRole

    // MARK: - Optional fields
    var weather: String?
    var result: String?
    var hitFactor: Double?
    var compScore: Double?
    var distanceToTarget: Double?
    var notes: String?
    var signature: Data?
    var instructorName: String?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Media storage (file names on disk)
    var photoFileNames: [String] = []
    var videoFileNames: [String] = []

    // MARK: - Relationships
    var weapon: Weapon?
    var range: ShootingRange?
    var instructor: Instructor?

    init(
        date: Date,
        numberOfShotsFired: Int,
        type: SessionType,
        sportType: String,
        role: SessionRole = .ampuja,
        weather: String? = nil,
        result: String? = nil,
        hitFactor: Double? = nil,
        compScore: Double? = nil,
        distanceToTarget: Double? = nil,
        notes: String? = nil,
        signature: Data? = nil,
        instructorName: String? = nil,
        weapon: Weapon? = nil,
        range: ShootingRange? = nil,
        instructor: Instructor? = nil
    ) {
        self.date = date
        self.numberOfShotsFired = numberOfShotsFired
        self.type = type
        self.sportType = sportType
        self.role = role
        self.weather = weather
        self.result = result
        self.hitFactor = hitFactor
        self.compScore = compScore
        self.distanceToTarget = distanceToTarget
        self.notes = notes
        self.signature = signature
        self.instructorName = instructorName
        self.weapon = weapon
        self.range = range
        self.instructor = instructor
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Session Media Storage

enum SessionMediaStorage {
    private static var mediaDirectoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("SessionMedia", isDirectory: true)
    }

    private static func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(at: mediaDirectoryURL, withIntermediateDirectories: true)
    }

    static func url(for fileName: String) -> URL {
        mediaDirectoryURL.appendingPathComponent(fileName)
    }

    static func saveImageData(_ data: Data) throws -> String {
        try ensureDirectoryExists()
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = mediaDirectoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return fileName
    }

    static func saveVideoCopy(from sourceURL: URL) throws -> String {
        try ensureDirectoryExists()

        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(ext)"
        let destinationURL = mediaDirectoryURL.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return fileName
    }

    static func deleteMedia(named fileName: String) {
        let fileURL = url(for: fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    static func deleteMedia(named fileNames: [String]) {
        fileNames.forEach(deleteMedia(named:))
    }

    static func isVideo(fileName: String) -> Bool {
        guard let type = UTType(filenameExtension: URL(fileURLWithPath: fileName).pathExtension) else {
            return false
        }
        return type.conforms(to: .movie) || type.conforms(to: .video)
    }
}
