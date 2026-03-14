import Foundation
import XCTest
@testable import BugNarrator

final class IssueExtractionServiceTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testExtractIssuesReturnsStructuredDraftIssues() async throws {
        let screenshot = SessionScreenshot(elapsedTime: 8, filePath: "/tmp/review-shot.png")
        let session = TranscriptSession(
            createdAt: Date(timeIntervalSince1970: 10),
            transcript: "The save button is clipped and the modal is confusing.",
            duration: 18,
            model: "whisper-1",
            languageHint: nil,
            prompt: nil,
            markers: [SessionMarker(index: 1, elapsedTime: 8, title: "Save flow", screenshotID: screenshot.id)],
            screenshots: [screenshot],
            sections: [
                TranscriptSection(
                    title: "Save flow",
                    startTime: 0,
                    endTime: 18,
                    text: "The save button is clipped and the modal is confusing.",
                    markerID: nil,
                    screenshotIDs: [screenshot.id]
                )
            ]
        )

        let content = """
        {
          "summary": "Two draft review items were extracted.",
          "guidanceNote": "Review these before export.",
          "issues": [
            {
              "title": "Save button clips in the modal",
              "category": "Bug",
              "summary": "The save button appears clipped in the modal layout.",
              "evidenceExcerpt": "The save button is clipped",
              "timestamp": "00:08",
              "sectionTitle": "Save flow",
              "relatedScreenshotFileNames": ["review-shot.png"],
              "confidence": 0.74,
              "requiresReview": true
            }
          ]
        }
        """

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api.openai.com/v1/chat/completions")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-key")

            let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = Data(#"{"choices":[{"message":{"content":"\#(content.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: ""))"}}]}"#.utf8)
            return (response, data)
        }

        let service = IssueExtractionService(session: makeMockURLSession())
        let result = try await service.extractIssues(from: session, apiKey: "test-key", model: "gpt-4.1-mini")

        XCTAssertEqual(result.summary, "Two draft review items were extracted.")
        XCTAssertEqual(result.guidanceNote, "Review these before export.")
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues.first?.category, .bug)
        XCTAssertEqual(result.issues.first?.relatedScreenshotIDs, [screenshot.id])
        XCTAssertEqual(result.issues.first?.timestamp, 8)
    }
}
