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

        Window("WindowPane Settings", id: "settings") {
            SettingsView()
                .environmentObject(store)
        }
        .windowResizability(.contentSize)
    }
}

struct MenuContent: View {
    @EnvironmentObject private var store: CommandStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if !Accessibility.isTrusted {
            Button("Enable Accessibility Permission…") {
                Accessibility.openSystemSettings()
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
            openSettingsWindow()
        }
        Button("Quit WindowPane") {
            NSApp.terminate(nil)
        }
    }

    private func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "settings")
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows
                .first { $0.title == "WindowPane Settings" }?
                .makeKeyAndOrderFront(nil)
        }
    }
}
