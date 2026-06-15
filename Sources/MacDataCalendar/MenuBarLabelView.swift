import AppKit
import Combine
import SwiftUI

struct MenuBarLabelView: View {
    @State private var now = Date()

    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "calendar")
                .font(.system(size: 15, weight: .regular))
                .symbolRenderingMode(.hierarchical)
            Text(dayOfMonth)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .offset(y: -3)
        }
        .onAppear { now = Date() }
        .onReceive(minuteTimer) { date in
            now = date
        }
        .contextMenu {
            Button("Выйти") {
                NSApplication.shared.terminate(nil)
            }
        }
        .accessibilityLabel("Календарь, \(dayOfMonth) число")
        .help("Открыть календарь")
    }

    private var dayOfMonth: String {
        "\(Calendar.current.component(.day, from: now))"
    }
}
