import SwiftUI

@main
struct MacDataCalendarApp: App {
    @StateObject private var navigator = MonthNavigator()

    var body: some Scene {
        MenuBarExtra {
            CalendarPopoverView(navigator: navigator)
        } label: {
            MenuBarLabelView()
        }
        .menuBarExtraStyle(.window)
    }
}
