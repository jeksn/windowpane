import SwiftUI
import KeyboardShortcuts
import ServiceManagement
import WindowPaneCore

struct GeneralSettingsView: View {
    @AppStorage(AppSettings.gapKey) private var gap: Double = 0
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var isTrusted = Accessibility.isTrusted

    var body: some View {
        Form {
            Section("Window Sizing") {
                HStack {
                    Text("Edge gap")
                    Spacer()
                    TextField("Gap", value: $gap, format: .number)
                        .frame(width: 76)
                        .multilineTextAlignment(.trailing)
                    Text("pt")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Hotkeys") {
                KeyboardShortcuts.Recorder("Quick Picker:", name: HotkeyManager.openPicker)
                KeyboardShortcuts.Recorder("Restore Previous Size:", name: HotkeyManager.restore)
            }
            Section {
                ForEach(WindowAction.all) { action in
                    KeyboardShortcuts.Recorder("\(action.name):", name: HotkeyManager.actionName(action.id))
                }
            } header: {
                Text("Actions")
            } footer: {
                Text("Parameterless actions — they keep the window's size and only change its position. Also available in the Quick Picker.")
            }
            Section("System") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { enabled in
                        do {
                            if enabled {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }
                HStack {
                    Label(
                        isTrusted ? "Accessibility granted" : "Accessibility permission required",
                        systemImage: isTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(isTrusted ? Color.green : Color.orange)
                    Spacer()
                    Button("Refresh") { isTrusted = Accessibility.isTrusted }
                    Button("Open System Settings") {
                        Accessibility.openSystemSettings()
                    }
                }
            }
            Section("URL Scheme") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("windowpane://apply?name=Left%20Half")
                    Text("windowpane://picker")
                    Text("windowpane://command?position=center&relativeWidth=0.5&relativeHeight=0.5")
                }
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            }
        }
        .formStyle(.grouped)
        .onAppear { isTrusted = Accessibility.isTrusted }
    }
}
