import Foundation

struct TranscriptSection: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    let markerID: UUID?
    let screenshotIDs: [UUID]

    init(
        id: UUID = UUID(),
        title: String,
        startTime: TimeInterval,
        endTime: TimeInterval,
        text: String,
        markerID: UUID?,
        screenshotIDs: [UUID]
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.markerID = markerID
        self.screenshotIDs = screenshotIDs
    }

    var timeRangeLabel: String {
        "\(ElapsedTimeFormatter.string(from: startTime)) - \(ElapsedTimeFormatter.string(from: endTime))"
    }
}
