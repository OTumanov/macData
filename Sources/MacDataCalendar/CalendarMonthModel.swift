import Foundation

struct DayCell: Equatable, Identifiable {
    let id: String
    let day: Int?
    let date: Date?
    let isToday: Bool
    let isCurrentMonth: Bool
    let dayKind: DayKind

    init(
        day: Int?,
        date: Date?,
        isToday: Bool,
        isCurrentMonth: Bool,
        dayKind: DayKind = .workday,
        leadingPadIndex: Int = 0
    ) {
        self.day = day
        self.date = date
        self.isToday = isToday
        self.isCurrentMonth = isCurrentMonth
        self.dayKind = dayKind
        if let date {
            self.id = "day-\(date.timeIntervalSinceReferenceDate)"
        } else {
            self.id = "pad-\(leadingPadIndex)"
        }
    }
}

enum CalendarMonthModel {
    static let gridLength = 42

    static func startOfMonth(for date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    static func makeMonthGrid(
        for monthAnchor: Date,
        calendar: Calendar = .current,
        now: Date = Date()
    ) -> [DayCell] {
        let monthStart = startOfMonth(for: monthAnchor, calendar: calendar)
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let firstWeekdayIndex = calendar.component(.weekday, from: monthStart)
        let leadingBlankCount = (firstWeekdayIndex - calendar.firstWeekday + 7) % 7

        var cells: [DayCell] = []
        for index in 0..<leadingBlankCount {
            cells.append(
                DayCell(day: nil, date: nil, isToday: false, isCurrentMonth: false, leadingPadIndex: index)
            )
        }

        for day in dayRange {
            var components = calendar.dateComponents([.year, .month], from: monthStart)
            components.day = day
            guard let date = calendar.date(from: components) else { continue }
            let isToday = calendar.isDate(date, inSameDayAs: now)
            let dayKind = DayClassifier.kind(for: date, calendar: calendar)
            cells.append(DayCell(day: day, date: date, isToday: isToday, isCurrentMonth: true, dayKind: dayKind))
        }

        var padIndex = 0
        while cells.count < gridLength {
            cells.append(
                DayCell(day: nil, date: nil, isToday: false, isCurrentMonth: false, leadingPadIndex: 1000 + padIndex)
            )
            padIndex += 1
        }

        return cells
    }

    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.shortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...]) + Array(symbols[..<start])
    }

    static func monthTitle(for monthAnchor: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .current
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return formatter.string(from: monthAnchor).capitalized(with: formatter.locale)
    }

    static func addMonths(_ value: Int, to monthAnchor: Date, calendar: Calendar = .current) -> Date {
        startOfMonth(
            for: calendar.date(byAdding: .month, value: value, to: monthAnchor) ?? monthAnchor,
            calendar: calendar
        )
    }
}
