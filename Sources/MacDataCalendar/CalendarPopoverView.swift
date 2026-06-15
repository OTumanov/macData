import SwiftUI

struct CalendarPopoverView: View {
    @ObservedObject var navigator: MonthNavigator
    @State private var showCopyConfirmation = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    navButton(systemName: "chevron.left", label: "Предыдущий месяц") {
                        navigator.goToPreviousMonth()
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(navigator.monthTitle)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Button("Сегодня") {
                            navigator.goToToday()
                        }
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .opacity(navigator.isShowingCurrentMonth ? 0 : 1)
                        .disabled(navigator.isShowingCurrentMonth)
                        .accessibilityHidden(navigator.isShowingCurrentMonth)
                        .accessibilityLabel("Вернуться к текущему месяцу")
                    }
                    .frame(height: CalendarTheme.headerBlockHeight)

                    Spacer()

                    navButton(systemName: "chevron.right", label: "Следующий месяц") {
                        navigator.goToNextMonth()
                    }
                }

                MonthGridView(
                    weekdaySymbols: navigator.weekdaySymbols,
                    cells: navigator.grid,
                    onCopyDate: copyDate
                )

                Divider()

                PopoverFooterView()
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if showCopyConfirmation {
                Text("Скопировано")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(CalendarTheme.hoverStripBackground)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(CalendarTheme.hoverStripBorder, lineWidth: 1)
                            }
                    }
                    .padding(.bottom, 52)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: CalendarTheme.popoverWidth, height: CalendarTheme.popoverHeight)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: showCopyConfirmation)
        .background {
            PopoverKeyHandler(
                onPreviousMonth: { navigator.goToPreviousMonth() },
                onNextMonth: { navigator.goToNextMonth() },
                onToday: { navigator.goToToday() }
            )
            .frame(width: 0, height: 0)
        }
        .accessibilityHint("Стрелки — месяц, T — сегодня")
    }

    private func copyDate(_ date: Date) {
        DayTooltipFormatter.copyToPasteboard(date)
        showCopyConfirmation = true
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            showCopyConfirmation = false
        }
    }

    private func navButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: CalendarTheme.navControlSize, height: CalendarTheme.navControlSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(NavIconButtonStyle())
        .accessibilityLabel(label)
    }
}

private struct NavIconButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            }
            .onHover { isHovered = $0 }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isPressed {
            return Color.primary.opacity(0.14)
        }
        if isHovered {
            return Color.primary.opacity(0.08)
        }
        return Color.clear
    }
}
