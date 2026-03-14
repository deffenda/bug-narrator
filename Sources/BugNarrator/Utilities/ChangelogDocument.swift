import Foundation

struct ChangelogDocument: Equatable {
    let title: String
    let markdown: String
    let latestHighlights: [String]

    init(title: String = "What’s New", markdown: String) {
        self.title = title
        self.markdown = markdown
        self.latestHighlights = Self.extractLatestHighlights(from: markdown)
    }

    init(bundle: Bundle = .main) {
        if let url = bundle.url(forResource: "CHANGELOG", withExtension: "md"),
           let data = try? Data(contentsOf: url),
           let markdown = String(data: data, encoding: .utf8),
           !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.init(markdown: markdown)
            return
        }

        self.init(markdown: """
        # Changelog

        ## 1.0.0

        - Initial BugNarrator product release.
        """)
    }

    init() {
        self.init(bundle: .main)
    }

    var attributedMarkdown: AttributedString {
        if let parsed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        ) {
            return parsed
        }

        return AttributedString(markdown)
    }

    private static func extractLatestHighlights(from markdown: String) -> [String] {
        var highlights: [String] = []
        var isInLatestSection = false

        for rawLine in markdown.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            if line.hasPrefix("## ") {
                if isInLatestSection {
                    break
                }

                isInLatestSection = true
                continue
            }

            guard isInLatestSection, line.hasPrefix("- ") else {
                continue
            }

            highlights.append(String(line.dropFirst(2)))
        }

        return Array(highlights.prefix(3))
    }
}
