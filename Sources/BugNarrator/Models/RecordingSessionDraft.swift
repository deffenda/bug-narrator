import Foundation

struct RecordingSessionDraft {
    let sessionID: UUID
    let artifactsDirectoryURL: URL
    var markers: [SessionMarker]
    var screenshots: [SessionScreenshot]

    init(
        sessionID: UUID,
        artifactsDirectoryURL: URL,
        markers: [SessionMarker] = [],
        screenshots: [SessionScreenshot] = []
    ) {
        self.sessionID = sessionID
        self.artifactsDirectoryURL = artifactsDirectoryURL
        self.markers = markers
        self.screenshots = screenshots
    }
}
