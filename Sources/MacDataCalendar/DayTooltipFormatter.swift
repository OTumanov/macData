import AppKit
import Foundation

enum DayTooltipFormatter {
    private static let hoverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return formatter
    }()

    private static let clipboardFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyyEEEE")
        return formatter
    }()

    static func hoverLine(for date: Date, dayKind: DayKind) -> String {
        let base = hoverFormatter.string(from: date)
        guard let suffix = dayKind.semanticSuffix else { return base }
        return "\(base) · \(suffix)"
    }

    static func clipboardString(for date: Date) -> String {
        clipboardFormatter.string(from: date)
    }

    static func copyToPasteboard(_ date: Date) {
        let string = clipboardString(for: date)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}
