import Foundation

/// Centralized date formatters configured for Finnish locale.
enum DateFormatters {
    /// Formats dates as "23.3.2026" (Finnish short format)
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fi_FI")
        formatter.dateStyle = .short
        return formatter
    }()

    /// Formats dates as "23. maaliskuuta 2026" (Finnish long format)
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fi_FI")
        formatter.dateStyle = .long
        return formatter
    }()

    /// Formats dates as "maaliskuu 2026" (month + year for grouping)
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fi_FI")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    /// Relative date formatter: "tänään", "eilen", "3 päivää sitten"
    nonisolated(unsafe) static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fi_FI")
        formatter.unitsStyle = .full
        return formatter
    }()
}
