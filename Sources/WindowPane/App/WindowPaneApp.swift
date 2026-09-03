import WindowPaneCore
import SwiftUI

@main
struct WindowPaneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = CommandStore.shared

    var body: some Scene {
        MenuBarExtra("WindowPane", systemImage: "rectangle.split.3x3") {
            MenuContent()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}

struct MenuContent: View {
    @EnvironmentObject private var store: CommandStore

    var body: some View {
        if !Accessibility.isTrusted {
            Button("Enable Accessibility Permission…") {
                NSWorkspace.shared.open(Accessibility.systemSettingsURL)
            }
            Divider()
        }

        ForEach(store.commands) { command in
            Button(command.name.isEmpty ? "Untitled" : command.name) {
                CommandApplier.shared.apply(command)
            }
        }

        Divider()
        Button("Restore Previous Size") {
            CommandApplier.shared.restore()
        }
        Button("Quick Picker…") {
            PickerController.shared.show()
        }
        Divider()
        Button("Settings…") {
            openSettings()
        }
        Button("Quit WindowPane") {
            NSApp.terminate(nil)
        }
    }
}

func openSettings() {
    NSApp.activate(ignoringOtherApps: true)
    for selector in ["showSettingsWindow:", "showPreferencesWindow:"] {
        if NSApp.sendAction(Selector(selector), to: nil, from: nil) {
            break
        }
    }
}
