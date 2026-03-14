import Foundation

struct SessionMarker: Identifiable, Codable, Equatable {
    let id: UUID
    let index: Int
    let elapsedTime: TimeInterval
    let createdAt: Date
    var title: String
    var note: String?
    let screenshotID: UUID?

    init(
        id: UUID = UUID(),
        index: Int,
        elapsedTime: TimeInterval,
        createdAt: Date = Date(),
        title: String,
        note: String? = nil,
        screenshotID: UUID?
    ) {
        self.id = id
        self.index = index
        self.elapsedTime = elapsedTime
        self.createdAt = createdAt
        self.title = title
        self.note = note
        self.screenshotID = screenshotID
    }

    var timeLabel: String {
        ElapsedTimeFormatter.string(from: elapsedTime)
    }
}
