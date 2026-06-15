import Foundation

enum DayKind: Equatable {
    case workday
    case weekend
    case holiday(String)

    /// Holiday/weekend label for tooltips and accessibility.
    var semanticSuffix: String? {
        switch self {
        case .workday:
            return nil
        case .weekend:
            return "Выходной"
        case .holiday(let title):
            return title
        }
    }
}

enum DayClassifier {
    static func kind(for date: Date, calendar: Calendar = .current) -> DayKind {
        let region = calendar.locale?.region?.identifier ?? Locale.current.region?.identifier ?? "RU"
        switch region {
        case "RU", "BY", "KZ":
            return RussianHolidayCalendar.kind(for: date, calendar: calendar)
        default:
            if calendar.isDateInWeekend(date) {
                return .weekend
            }
            return .workday
        }
    }
}

/// Russian Federation public holidays and official transferred days off (производственный календарь).
enum RussianHolidayCalendar {
    private struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    private static let recurringHolidays: [MonthDay: String] = [
        MonthDay(month: 1, day: 1): "Новый год",
        MonthDay(month: 1, day: 2): "Новогодние каникулы",
        MonthDay(month: 1, day: 3): "Новогодние каникулы",
        MonthDay(month: 1, day: 4): "Новогодние каникулы",
        MonthDay(month: 1, day: 5): "Новогодние каникулы",
        MonthDay(month: 1, day: 6): "Новогодние каникулы",
        MonthDay(month: 1, day: 7): "Рождество",
        MonthDay(month: 1, day: 8): "Новогодние каникулы",
        MonthDay(month: 2, day: 23): "День защитника Отечества",
        MonthDay(month: 3, day: 8): "Международный женский день",
        MonthDay(month: 5, day: 1): "Праздник Весны и Труда",
        MonthDay(month: 5, day: 9): "День Победы",
        MonthDay(month: 6, day: 12): "День России",
        MonthDay(month: 11, day: 4): "День народного единства",
    ]

    /// Extra non-working days by year (bridges and transfers), yyyy-MM-dd.
    private static let extraDaysOff: [Int: Set<String>] = [
        2025: ["2025-12-31"],
        2026: [
            "2026-01-09", "2026-01-10", "2026-01-11",
            "2026-02-21", "2026-02-22",
            "2026-03-07", "2026-03-09",
            "2026-05-02", "2026-05-03", "2026-05-10", "2026-05-11",
            "2026-06-13", "2026-06-14",
            "2026-12-31",
        ],
        2027: [],
    ]

    static func kind(for date: Date, calendar: Calendar) -> DayKind {
        if let title = holidayTitle(for: date, calendar: calendar) {
            return .holiday(title)
        }
        if calendar.isDateInWeekend(date) {
            return .weekend
        }
        if isExtraDayOff(date, calendar: calendar) {
            return .holiday("Выходной")
        }
        return .workday
    }

    static func holidayTitle(for date: Date, calendar: Calendar) -> String? {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        guard let month = parts.month, let day = parts.day else { return nil }

        if let title = recurringHolidays[MonthDay(month: month, day: day)] {
            return title
        }
        if isExtraDayOff(date, calendar: calendar) {
            return "Выходной"
        }
        return nil
    }

    private static func isExtraDayOff(_ date: Date, calendar: Calendar) -> Bool {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return false }
        let key = String(format: "%04d-%02d-%02d", year, month, day)
        if extraDaysOff[year, default: []].contains(key) { return true }
        return false
    }
}
