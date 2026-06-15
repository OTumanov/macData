import AppKit
import SwiftUI

struct PopoverFooterView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @State private var loginError: String?
    @State private var ignoreToggleChange = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Toggle("Запускать при входе", isOn: $launchAtLogin)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                    .onChange(of: launchAtLogin) { _, newValue in
                        applyLaunchAtLogin(newValue)
                    }

                Spacer()

                Button("Выйти") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Выйти из MacData Calendar")
            }

            if let loginError {
                Text(loginError)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(height: CalendarTheme.footerBlockHeight)
        .onAppear {
            syncFromService()
        }
    }

    private func syncFromService() {
        ignoreToggleChange = true
        launchAtLogin = LaunchAtLoginService.isEnabled
        loginError = nil
        ignoreToggleChange = false
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        guard !ignoreToggleChange else { return }
        do {
            try LaunchAtLoginService.setEnabled(enabled)
            loginError = nil
        } catch {
            ignoreToggleChange = true
            launchAtLogin = LaunchAtLoginService.isEnabled
            ignoreToggleChange = false
            loginError = "Не удалось добавить в автозапуск"
        }
    }
}
