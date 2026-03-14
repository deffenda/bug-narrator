import Foundation

enum ExtractedIssueCategory: String, Codable, CaseIterable, Identifiable {
    case bug = "Bug"
    case uxIssue = "UX Issue"
    case enhancement = "Enhancement"
    case followUp = "Question / Follow-up"

    var id: String { rawValue }
}

struct ExtractedIssue: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: ExtractedIssueCategory
    var summary: String
    var evidenceExcerpt: String
    var timestamp: TimeInterval?
    var relatedScreenshotIDs: [UUID]
    var confidence: Double?
    var requiresReview: Bool
    var isSelectedForExport: Bool
    var sectionTitle: String?
    var note: String?

    init(
        id: UUID = UUID(),
        title: String,
        category: ExtractedIssueCategory,
        summary: String,
        evidenceExcerpt: String,
        timestamp: TimeInterval?,
        relatedScreenshotIDs: [UUID] = [],
        confidence: Double? = nil,
        requiresReview: Bool = true,
        isSelectedForExport: Bool = true,
        sectionTitle: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.summary = summary
        self.evidenceExcerpt = evidenceExcerpt
        self.timestamp = timestamp
        self.relatedScreenshotIDs = relatedScreenshotIDs
        self.confidence = confidence
        self.requiresReview = requiresReview
        self.isSelectedForExport = isSelectedForExport
        self.sectionTitle = sectionTitle
        self.note = note
    }

    var timestampLabel: String? {
        guard let timestamp else {
            return nil
        }

        return ElapsedTimeFormatter.string(from: timestamp)
    }

    var confidenceLabel: String? {
        guard let confidence else {
            return nil
        }

        return "\(Int((confidence * 100).rounded()))%"
    }
}

struct IssueExtractionResult: Codable, Equatable {
    let generatedAt: Date
    var summary: String
    var guidanceNote: String
    var issues: [ExtractedIssue]

    init(
        generatedAt: Date = Date(),
        summary: String,
        guidanceNote: String = "Extracted issues are draft suggestions and should be reviewed before export.",
        issues: [ExtractedIssue]
    ) {
        self.generatedAt = generatedAt
        self.summary = summary
        self.guidanceNote = guidanceNote
        self.issues = issues
    }

    var selectedIssues: [ExtractedIssue] {
        issues.filter(\.isSelectedForExport)
    }
}

enum ExportDestination: String, Codable, CaseIterable, Identifiable {
    case github = "GitHub"
    case jira = "Jira"

    var id: String { rawValue }

    var actionTitle: String {
        "Export to \(rawValue)"
    }
}

struct ExportResult: Identifiable, Equatable {
    let id: UUID
    let sourceIssueID: UUID
    let destination: ExportDestination
    let remoteIdentifier: String
    let remoteURL: URL?
    let exportedAt: Date

    init(
        id: UUID = UUID(),
        sourceIssueID: UUID,
        destination: ExportDestination,
        remoteIdentifier: String,
        remoteURL: URL?,
        exportedAt: Date = Date()
    ) {
        self.id = id
        self.sourceIssueID = sourceIssueID
        self.destination = destination
        self.remoteIdentifier = remoteIdentifier
        self.remoteURL = remoteURL
        self.exportedAt = exportedAt
    }
}

struct GitHubExportConfiguration: Equatable {
    let token: String
    let owner: String
    let repository: String
    let labels: [String]

    var isComplete: Bool {
        !token.isEmpty && !owner.isEmpty && !repository.isEmpty
    }
}

struct JiraExportConfiguration: Equatable {
    let baseURL: URL
    let email: String
    let apiToken: String
    let projectKey: String
    let issueType: String

    var isComplete: Bool {
        !email.isEmpty && !apiToken.isEmpty && !projectKey.isEmpty && !issueType.isEmpty
    }
}
