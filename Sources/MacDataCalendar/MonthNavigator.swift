import Combine
import Foundation

@MainActor
final class MonthNavigator: ObservableObject {
    @Published private(set) var displayedMonth: Date
    @Published private(set) var grid: [DayCell] = []

    private let calendar: Calendar
    private let weekdaySymbolsCache: [String]

    init(calendar: Calendar = .current, now: Date = Date()) {
        self.calendar = calendar
        self.displayedMonth = CalendarMonthModel.startOfMonth(for: now, calendar: calendar)
        self.weekdaySymbolsCache = CalendarMonthModel.weekdaySymbols(calendar: calendar)
        refreshGrid(now: now)
    }

    var monthTitle: String {
        CalendarMonthModel.monthTitle(for: displayedMonth, calendar: calendar)
    }

    var weekdaySymbols: [String] {
        weekdaySymbolsCache
    }

    var isShowingCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    func goToPreviousMonth() {
        displayedMonth = CalendarMonthModel.addMonths(-1, to: displayedMonth, calendar: calendar)
        refreshGrid()
    }

    func goToNextMonth() {
        displayedMonth = CalendarMonthModel.addMonths(1, to: displayedMonth, calendar: calendar)
        refreshGrid()
    }

    func resetToCurrentMonth() {
        displayedMonth = CalendarMonthModel.startOfMonth(for: Date(), calendar: calendar)
        refreshGrid()
    }

    func goToToday() {
        resetToCurrentMonth()
    }

    private func refreshGrid(now: Date = Date()) {
        grid = CalendarMonthModel.makeMonthGrid(for: displayedMonth, calendar: calendar, now: now)
    }
}
