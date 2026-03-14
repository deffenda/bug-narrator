import Foundation

final class TranscriptStore: ObservableObject {
    @Published private(set) var sessions: [TranscriptSession] = []

    private enum StoragePolicy {
        static let maximumStoredSessions = 500
    }

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageURL: URL
    private let backupStorageURL: URL

    init(fileManager: FileManager = .default, storageURL: URL? = nil) {
        self.fileManager = fileManager

        if let storageURL {
            self.storageURL = storageURL
        } else {
            let appSupportDirectory = Self.makeAppSupportDirectory(fileManager: fileManager)
            self.storageURL = appSupportDirectory.appendingPathComponent("sessions.json")
        }
        self.backupStorageURL = Self.makeBackupURL(for: self.storageURL)

        load()
    }

    func add(_ session: TranscriptSession) throws {
        var updatedSessions = sessions
        updatedSessions.removeAll { $0.id == session.id }
        updatedSessions.insert(session, at: 0)
        updatedSessions = normalizedSessions(updatedSessions)

        do {
            try persist(updatedSessions)
            sessions = updatedSessions
        } catch {
            throw AppError.storageFailure(error.localizedDescription)
        }
    }

    @discardableResult
    func removeSessions(withIDs ids: Set<UUID>) throws -> [TranscriptSession] {
        guard !ids.isEmpty else {
            return []
        }

        let removedSessions = sessions.filter { ids.contains($0.id) }
        let remainingSessions = sessions.filter { !ids.contains($0.id) }

        do {
            try persist(remainingSessions)
            sessions = remainingSessions
            return removedSessions
        } catch {
            throw AppError.storageFailure(error.localizedDescription)
        }
    }

    func session(with id: UUID) -> TranscriptSession? {
        sessions.first { $0.id == id }
    }

    private func load() {
        if let storedSessions = loadSessions(from: storageURL) {
            sessions = normalizedSessions(storedSessions)
            return
        }

        if let backupSessions = loadSessions(from: backupStorageURL) {
            let normalizedBackupSessions = normalizedSessions(backupSessions)
            sessions = normalizedBackupSessions
            try? persist(normalizedBackupSessions)
            return
        }

        sessions = []
    }

    private func persist(_ sessions: [TranscriptSession]) throws {
        let parentDirectoryURL = storageURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDirectoryURL.path) {
            try fileManager.createDirectory(at: parentDirectoryURL, withIntermediateDirectories: true)
        }

        let data = try encoder.encode(sessions)
        try data.write(to: storageURL, options: [.atomic])
        try? data.write(to: backupStorageURL, options: [.atomic])
    }

    private func loadSessions(from url: URL) -> [TranscriptSession]? {
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([TranscriptSession].self, from: data)
        } catch {
            return nil
        }
    }

    private func normalizedSessions(_ sessions: [TranscriptSession]) -> [TranscriptSession] {
        let uniqueSessions = Dictionary(uniqueKeysWithValues: sessions.map { ($0.id, $0) }).values
        return Array(uniqueSessions)
            .sorted { lhs, rhs in
                if lhs.createdAt == rhs.createdAt {
                    return lhs.id.uuidString > rhs.id.uuidString
                }

                return lhs.createdAt > rhs.createdAt
            }
            .prefix(StoragePolicy.maximumStoredSessions)
            .map { $0 }
    }

    private static func makeAppSupportDirectory(fileManager: FileManager) -> URL {
        AppSupportLocation.appDirectory(fileManager: fileManager)
    }

    private static func makeBackupURL(for storageURL: URL) -> URL {
        storageURL.deletingPathExtension().appendingPathExtension("backup.json")
    }
}
