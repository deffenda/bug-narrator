import Foundation

actor ExportService: IssueExporting {
    private let gitHubProvider: GitHubExportProvider
    private let jiraProvider: JiraExportProvider

    init(
        gitHubProvider: GitHubExportProvider = GitHubExportProvider(),
        jiraProvider: JiraExportProvider = JiraExportProvider()
    ) {
        self.gitHubProvider = gitHubProvider
        self.jiraProvider = jiraProvider
    }

    func exportToGitHub(
        issues: [ExtractedIssue],
        session: TranscriptSession,
        configuration: GitHubExportConfiguration
    ) async throws -> [ExportResult] {
        try await gitHubProvider.export(issues: issues, session: session, configuration: configuration)
    }

    func exportToJira(
        issues: [ExtractedIssue],
        session: TranscriptSession,
        configuration: JiraExportConfiguration
    ) async throws -> [ExportResult] {
        try await jiraProvider.export(issues: issues, session: session, configuration: configuration)
    }
}
