import Foundation
@testable import MacDataCalendar
import XCTest

final class CalendarMonthModelTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        cal.firstWeekday = 2
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func testJune2026StartsOnMonday() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 1
        let month = try XCTUnwrap(calendar.date(from: components))
        let grid = CalendarMonthModel.makeMonthGrid(
            for: month,
            calendar: calendar,
            now: try XCTUnwrap(calendar.date(from: components))
        )

        let firstDay = try XCTUnwrap(grid.first(where: { $0.day != nil }))
        XCTAssertEqual(firstDay.day, 1)
        XCTAssertEqual(grid.filter { $0.isCurrentMonth && $0.day != nil }.count, 30)
    }

    func testFebruary2024LeapYearHas29Days() throws {
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 15
        let month = try XCTUnwrap(calendar.date(from: components))
        let grid = CalendarMonthModel.makeMonthGrid(for: month, calendar: calendar, now: month)

        XCTAssertEqual(grid.filter { $0.isCurrentMonth && $0.day != nil }.count, 29)
    }

    func testLeadingPaddingBeforeFirstDay() throws {
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 1
        let month = try XCTUnwrap(calendar.date(from: components))

        let grid = CalendarMonthModel.makeMonthGrid(for: month, calendar: calendar, now: month)
        let leading = grid.prefix(while: { $0.day == nil }).count
        XCTAssertEqual(leading, 3)
    }

    func testTodayFlag() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 15
        let month = try XCTUnwrap(calendar.date(from: components))
        let now = try XCTUnwrap(calendar.date(from: components))
        let grid = CalendarMonthModel.makeMonthGrid(for: month, calendar: calendar, now: now)

        let todayCells = grid.filter(\.isToday)
        XCTAssertEqual(todayCells.count, 1)
        XCTAssertEqual(todayCells.first?.day, 15)
    }

    func testMonthNavigationCrossesYear() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 1
        let december = try XCTUnwrap(calendar.date(from: components))
        let january = CalendarMonthModel.addMonths(1, to: december, calendar: calendar)

        XCTAssertEqual(calendar.component(.month, from: january), 1)
        XCTAssertEqual(calendar.component(.year, from: january), 2027)
    }

    func testWeekdaySymbolsRotateFromMonday() {
        let symbols = CalendarMonthModel.weekdaySymbols(calendar: calendar)
        XCTAssertEqual(symbols.first, calendar.shortWeekdaySymbols[1])
    }

    func testGridLengthIsSixWeeks() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 1
        let month = try XCTUnwrap(calendar.date(from: components))
        let grid = CalendarMonthModel.makeMonthGrid(for: month, calendar: calendar, now: month)
        XCTAssertEqual(grid.count, CalendarMonthModel.gridLength)
    }
}

final class DayClassifierTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        cal.firstWeekday = 2
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func testSaturdayIsWeekend() throws {
        let date = try makeDate(year: 2026, month: 6, day: 13)
        XCTAssertEqual(DayClassifier.kind(for: date, calendar: calendar), .weekend)
    }

    func testRussiaDayIsHoliday() throws {
        let date = try makeDate(year: 2026, month: 6, day: 12)
        XCTAssertEqual(DayClassifier.kind(for: date, calendar: calendar), .holiday("День России"))
    }

    func testRegularMondayIsWorkday() throws {
        let date = try makeDate(year: 2026, month: 6, day: 15)
        XCTAssertEqual(DayClassifier.kind(for: date, calendar: calendar), .workday)
    }

    func testTransferredJanuaryBridgeIsDayOff() throws {
        let date = try makeDate(year: 2026, month: 1, day: 9)
        XCTAssertEqual(DayClassifier.kind(for: date, calendar: calendar), .holiday("Выходной"))
    }

    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return try XCTUnwrap(calendar.date(from: components))
    }
}
