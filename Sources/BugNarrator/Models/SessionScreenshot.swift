import Foundation

struct SessionScreenshot: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let elapsedTime: TimeInterval
    let filePath: String
    let associatedMarkerID: UUID?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        elapsedTime: TimeInterval,
        filePath: String,
        associatedMarkerID: UUID? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.elapsedTime = elapsedTime
        self.filePath = filePath
        self.associatedMarkerID = associatedMarkerID
    }

    var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }

    var fileName: String {
        fileURL.lastPathComponent
    }

    var timeLabel: String {
        ElapsedTimeFormatter.string(from: elapsedTime)
    }
}
