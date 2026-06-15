import SwiftUI

struct MonthGridView: View {
    let weekdaySymbols: [String]
    let cells: [DayCell]
    var onCopyDate: (Date) -> Void = { _ in }

    @State private var hoveredCellID: DayCell.ID?
    @State private var hoverLine: String?

    private let calendar = Calendar.current
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: CalendarTheme.gridGap),
        count: 7
    )

    var body: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: columns, spacing: CalendarTheme.gridGap) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(
                            isWeekendColumn(index)
                                ? CalendarTheme.weekendInk.opacity(0.85)
                                : Color.secondary
                        )
                        .frame(maxWidth: .infinity)
                }
            }

            hoverStrip

            LazyVGrid(columns: columns, spacing: CalendarTheme.gridGap) {
                ForEach(cells) { cell in
                    dayCellView(cell)
                }
            }
        }
    }

    private var hoverStrip: some View {
        Text(hoverLine ?? " ")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(hoverLine == nil ? Color.clear : Color.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: CalendarTheme.hoverStripHeight)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(CalendarTheme.hoverStripBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(CalendarTheme.hoverStripBorder, lineWidth: 1)
                    }
                    .opacity(hoverLine == nil ? 0.35 : 1)
            }
            .accessibilityHidden(hoverLine == nil)
            .accessibilityLabel(hoverLine ?? "")
    }

    @ViewBuilder
    private func dayCellView(_ cell: DayCell) -> some View {
        if let day = cell.day, let date = cell.date {
            Button {
                onCopyDate(date)
            } label: {
                ZStack {
                    dayBackground(for: cell)
                    Text("\(day)")
                        .font(.system(size: 13, weight: fontWeight(for: cell)))
                }
                .frame(width: CalendarTheme.dayCellSize, height: CalendarTheme.dayCellSize)
                .foregroundStyle(foregroundColor(for: cell))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    hoveredCellID = cell.id
                    hoverLine = DayTooltipFormatter.hoverLine(for: date, dayKind: cell.dayKind)
                } else if hoveredCellID == cell.id {
                    hoveredCellID = nil
                    hoverLine = nil
                }
            }
            .accessibilityLabel(DayAccessibility.label(for: cell, date: date))
            .accessibilityHint("Нажмите, чтобы скопировать дату")
        } else {
            Color.clear
                .frame(width: CalendarTheme.dayCellSize, height: CalendarTheme.dayCellSize)
        }
    }

    @ViewBuilder
    private func dayBackground(for cell: DayCell) -> some View {
        let size = CalendarTheme.dayMarkerSize

        if cell.isToday {
            Circle()
                .strokeBorder(CalendarTheme.todayRing, lineWidth: 1.5)
                .frame(width: size, height: size)
        } else if case .holiday = cell.dayKind {
            Circle()
                .fill(CalendarTheme.holidayFill)
                .frame(width: size, height: size)
        }
    }

    private func foregroundColor(for cell: DayCell) -> Color {
        switch cell.dayKind {
        case .workday:
            return .primary
        case .weekend, .holiday:
            return CalendarTheme.weekendInk
        }
    }

    private func fontWeight(for cell: DayCell) -> Font.Weight {
        if cell.isToday { return .semibold }
        switch cell.dayKind {
        case .workday:
            return .regular
        case .weekend, .holiday:
            return .semibold
        }
    }

    private func isWeekendColumn(_ index: Int) -> Bool {
        let weekday = (calendar.firstWeekday - 1 + index) % 7 + 1
        var components = DateComponents()
        components.weekday = weekday
        guard let reference = calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) else {
            return weekday == 1 || weekday == 7
        }
        return calendar.isDateInWeekend(reference)
    }
}

private enum DayAccessibility {
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        return formatter
    }()

    static func label(for cell: DayCell, date: Date) -> String {
        var label = fullDateFormatter.string(from: date)
        if case let .holiday(title) = cell.dayKind {
            label += ", \(title)"
        } else if cell.dayKind == .weekend {
            label += ", выходной"
        }
        if cell.isToday {
            label += ", сегодня"
        }
        return label
    }
}
