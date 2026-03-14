import Foundation

enum SessionLibraryDateFilter: String, CaseIterable, Identifiable {
    case today = "Today"
    case yesterday = "Yesterday"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case allSessions = "All Sessions"
    case customRange = "Custom Date Range"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .today:
            return "sun.max"
        case .yesterday:
            return "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .last7Days:
            return "calendar"
        case .last30Days:
            return "calendar.badge.clock"
        case .allSessions:
            return "square.stack.3d.up"
        case .customRange:
            return "calendar.badge.plus"
        }
    }
}

enum SessionLibrarySortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"

    var id: String { rawValue }
}

struct SessionLibraryDateRange: Equatable {
    var startDate: Date
    var endDate: Date

    func normalized(in calendar: Calendar) -> ClosedRange<Date> {
        let lowerBound = min(startDate, endDate)
        let upperBound = max(startDate, endDate)
        let startOfLowerBound = calendar.startOfDay(for: lowerBound)
        let startOfUpperBound = calendar.startOfDay(for: upperBound)
        let inclusiveUpperBound = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfUpperBound)
            ?? upperBound
        return startOfLowerBound ... inclusiveUpperBound
    }
}

struct SessionLibraryQuery: Equatable {
    var filter: SessionLibraryDateFilter
    var customDateRange: SessionLibraryDateRange
    var searchText: String = ""
    var sortOrder: SessionLibrarySortOrder = .newestFirst
}

enum SessionLibraryEmptyState: Equatable {
    case noSessionsYet
    case noSessionsInFilter(SessionLibraryDateFilter)
    case noSessionsInCustomRange
    case noSearchResults

    var title: String {
        switch self {
        case .noSessionsYet:
            return "No Sessions Yet"
        case .noSessionsInFilter(let filter):
            return "No Sessions in \(filter.rawValue)"
        case .noSessionsInCustomRange:
            return "No Sessions in Date Range"
        case .noSearchResults:
            return "No Matching Sessions"
        }
    }

    var description: String {
        switch self {
        case .noSessionsYet:
            return "Start and stop a review session to build your BugNarrator library."
        case .noSessionsInFilter(let filter):
            return "There are no saved sessions in \(filter.rawValue.lowercased()) yet."
        case .noSessionsInCustomRange:
            return "Try widening the selected date range to include more sessions."
        case .noSearchResults:
            return "Try a different search term or clear the search field."
        }
    }

    var systemImage: String {
        switch self {
        case .noSessionsYet:
            return "text.quote"
        case .noSessionsInFilter, .noSessionsInCustomRange:
            return "calendar.badge.exclamationmark"
        case .noSearchResults:
            return "magnifyingglass"
        }
    }
}

enum SessionLibrary {
    static func filteredSessions(
        from sessions: [TranscriptSession],
        query: SessionLibraryQuery,
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> [TranscriptSession] {
        let dateFilteredSessions = sessions.filter {
            matchesDateFilter($0, filter: query.filter, customDateRange: query.customDateRange, calendar: calendar, referenceDate: referenceDate)
        }

        let searchText = normalizedSearchText(query.searchText)
        let searchFilteredSessions: [TranscriptSession]
        if searchText.isEmpty {
            searchFilteredSessions = dateFilteredSessions
        } else {
            searchFilteredSessions = dateFilteredSessions.filter { session in
                session.searchIndexText.contains(searchText)
            }
        }

        return searchFilteredSessions.sorted { lhs, rhs in
            switch query.sortOrder {
            case .newestFirst:
                if lhs.createdAt == rhs.createdAt {
                    return lhs.id.uuidString > rhs.id.uuidString
                }
                return lhs.createdAt > rhs.createdAt
            case .oldestFirst:
                if lhs.createdAt == rhs.createdAt {
                    return lhs.id.uuidString < rhs.id.uuidString
                }
                return lhs.createdAt < rhs.createdAt
            }
        }
    }

    static func count(
        for filter: SessionLibraryDateFilter,
        in sessions: [TranscriptSession],
        customDateRange: SessionLibraryDateRange,
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> Int {
        sessions.filter {
            matchesDateFilter($0, filter: filter, customDateRange: customDateRange, calendar: calendar, referenceDate: referenceDate)
        }.count
    }

    static func emptyState(
        allSessions: [TranscriptSession],
        filteredSessions: [TranscriptSession],
        query: SessionLibraryQuery
    ) -> SessionLibraryEmptyState? {
        guard filteredSessions.isEmpty else {
            return nil
        }

        guard !allSessions.isEmpty else {
            return .noSessionsYet
        }

        if !normalizedSearchText(query.searchText).isEmpty {
            return .noSearchResults
        }

        switch query.filter {
        case .customRange:
            return .noSessionsInCustomRange
        case .allSessions:
            return .noSessionsYet
        default:
            return .noSessionsInFilter(query.filter)
        }
    }

    private static func matchesDateFilter(
        _ session: TranscriptSession,
        filter: SessionLibraryDateFilter,
        customDateRange: SessionLibraryDateRange,
        calendar: Calendar,
        referenceDate: Date
    ) -> Bool {
        switch filter {
        case .today:
            return calendar.isDate(session.createdAt, inSameDayAs: referenceDate)
        case .yesterday:
            return calendar.isDate(session.createdAt, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate)
        case .last7Days:
            return recentWindow(dayCount: 7, calendar: calendar, referenceDate: referenceDate).contains(session.createdAt)
        case .last30Days:
            return recentWindow(dayCount: 30, calendar: calendar, referenceDate: referenceDate).contains(session.createdAt)
        case .allSessions:
            return true
        case .customRange:
            return customDateRange.normalized(in: calendar).contains(session.createdAt)
        }
    }

    private static func recentWindow(
        dayCount: Int,
        calendar: Calendar,
        referenceDate: Date
    ) -> ClosedRange<Date> {
        let startOfReferenceDate = calendar.startOfDay(for: referenceDate)
        let lowerBound = calendar.date(byAdding: .day, value: -(dayCount - 1), to: startOfReferenceDate) ?? startOfReferenceDate
        let upperBound = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfReferenceDate) ?? referenceDate
        return lowerBound ... upperBound
    }

    private static func normalizedSearchText(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
