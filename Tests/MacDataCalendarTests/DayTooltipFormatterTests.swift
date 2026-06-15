import Foundation
@testable import MacDataCalendar
import XCTest

final class DayTooltipFormatterTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func testHoverLineIncludesWeekdayAndMonth() throws {
        let date = try makeDate(year: 2026, month: 6, day: 15)
        let line = DayTooltipFormatter.hoverLine(for: date, dayKind: .workday)
        XCTAssertTrue(line.contains("15"))
        XCTAssertTrue(line.contains("июн"))
    }

    func testHoverLineAppendsHolidaySuffix() throws {
        let date = try makeDate(year: 2026, month: 6, day: 12)
        let line = DayTooltipFormatter.hoverLine(for: date, dayKind: .holiday("День России"))
        XCTAssertTrue(line.contains("·"))
        XCTAssertTrue(line.contains("День России"))
    }

    func testHoverLineAppendsWeekendSuffix() throws {
        let date = try makeDate(year: 2026, month: 6, day: 13)
        let line = DayTooltipFormatter.hoverLine(for: date, dayKind: .weekend)
        XCTAssertTrue(line.contains("·"))
        XCTAssertTrue(line.contains("Выходной"))
    }

    func testClipboardStringIncludesDayMonthYearWeekday() throws {
        let date = try makeDate(year: 2026, month: 6, day: 15)
        let copied = DayTooltipFormatter.clipboardString(for: date)
        XCTAssertTrue(copied.contains("15"))
        XCTAssertTrue(copied.contains("2026"))
    }

    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return try XCTUnwrap(calendar.date(from: components))
    }
}
