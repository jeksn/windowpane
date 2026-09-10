import AppKit
import KeyboardShortcuts
import SwiftUI
import WindowPaneCore

struct AppShortcutEditorView: View {
    @Binding var shortcut: AppShortcut
    var onDelete: (() -> Void)?

    @State private var showingChooser = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        Form {
            Section("Shortcut") {
                TextField("Name", text: $shortcut.name)

                Picker("Kind", selection: $shortcut.isURL) {
                    Text("App").tag(false)
                    Text("URL / Link").tag(true)
                }
                .pickerStyle(.segmented)
            }

            if shortcut.isURL {
                Section("URL") {
                    TextField("URL", text: urlStringBinding)
                        .textFieldStyle(.roundedBorder)
                    if let url = shortcut.url {
                        Text(url.absoluteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else if shortcut.urlString?.isEmpty == false {
                        Text("Invalid URL")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            } else {
                Section("App") {
                    HStack(spacing: 12) {
                        appIcon
                            .frame(width: 32, height: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(shortcut.name.isEmpty ? "No app selected" : shortcut.name)
                                .lineLimit(1)
                            if let bundleID = shortcut.bundleIdentifier, !bundleID.isEmpty {
                                Text(bundleID)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Button("Choose…") { showingChooser = true }
                    }
                }
            }

            Section("Hotkey") {
                KeyboardShortcuts.Recorder("Hotkey:", name: HotkeyManager.appJumpName(for: shortcut.id))
            }

            Section("Danger Zone") {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Text("Delete Shortcut…")
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingChooser) {
            AppChooserView { item in
                chooseApp(item)
            }
        }
        .confirmationDialog(
            "Delete \"\(shortcut.name)\"?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This shortcut and its hotkey will be removed. This cannot be undone.")
        }
    }

    private var urlStringBinding: Binding<String> {
        Binding(
            get: { shortcut.urlString ?? "" },
            set: { newValue in
                shortcut.urlString = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private func chooseApp(_ item: AppChooserItem) {
        shortcut.name = item.name
        shortcut.bundleIdentifier = item.bundleIdentifier
        shortcut.bundleURL = item.bundleURL
    }

    @ViewBuilder
    private var appIcon: some View {
        let image: NSImage? = {
            if let bundleID = shortcut.bundleIdentifier, !bundleID.isEmpty,
               let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                return NSWorkspace.shared.icon(forFile: url.path)
            } else if let bundleURL = shortcut.bundleURL {
                return NSWorkspace.shared.icon(forFile: bundleURL.path)
            }
            return nil
        }()

        if let nsImage = image {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
        }
    }
}
