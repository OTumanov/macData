import AppKit
import SwiftUI

/// Visual tokens from DESIGN.md — single source for popover styling.
enum CalendarTheme {
    static let popoverWidth: CGFloat = 280
    static let popoverHeight: CGFloat = 356
    static let headerBlockHeight: CGFloat = 36
    static let footerBlockHeight: CGFloat = 28
    static let dayCellSize: CGFloat = 28
    static let dayMarkerSize: CGFloat = 26
    static let navControlSize: CGFloat = 28
    static let gridGap: CGFloat = 4
    static let hoverStripHeight: CGFloat = 22

    static let weekendInk = Color(nsColor: dynamicWeekendInk)
    static let holidayFill = Color(nsColor: dynamicHolidayFill)
    static let todayRing = Color(nsColor: dynamicTodayRing)
    static let hoverStripBackground = Color(nsColor: dynamicHoverStripBackground)
    static let hoverStripBorder = Color(nsColor: dynamicHoverStripBorder)

    private static let dynamicWeekendInk = NSColor(name: nil, dynamicProvider: { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark {
            return NSColor(calibratedRed: 0.96, green: 0.44, blue: 0.40, alpha: 1)
        }
        return NSColor(calibratedRed: 0.82, green: 0.22, blue: 0.22, alpha: 1)
    })

    private static let dynamicHolidayFill = NSColor(name: nil, dynamicProvider: { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark {
            return NSColor(calibratedRed: 0.96, green: 0.44, blue: 0.40, alpha: 0.22)
        }
        return NSColor(calibratedRed: 0.90, green: 0.28, blue: 0.24, alpha: 0.18)
    })

    /// Neutral ring — avoids clashing with red holiday fills when system accent is green.
    private static let dynamicTodayRing = NSColor(name: nil, dynamicProvider: { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark {
            return NSColor.labelColor.withAlphaComponent(0.72)
        }
        return NSColor.labelColor.withAlphaComponent(0.55)
    })

    private static let dynamicHoverStripBackground = NSColor(name: nil, dynamicProvider: { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark {
            return NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.26, alpha: 1)
        }
        return NSColor(calibratedRed: 0.94, green: 0.94, blue: 0.96, alpha: 1)
    })

    private static let dynamicHoverStripBorder = NSColor(name: nil, dynamicProvider: { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark {
            return NSColor.white.withAlphaComponent(0.12)
        }
        return NSColor.black.withAlphaComponent(0.08)
    })
}
