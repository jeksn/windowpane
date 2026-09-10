import KeyboardShortcuts
import SwiftUI
import WindowPaneCore

struct AppShortcutListView: View {
    @EnvironmentObject private var store: AppShortcutStore
    @State private var selectionID: UUID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectionID) {
                Section {
                    ForEach(store.shortcuts) { shortcut in
                        row(for: shortcut)
                    }
                    .onMove { store.move(from: $0, to: $1) }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            .toolbar {
                ToolbarItem {
                    HStack(spacing: 8) {
                        Button {
                            let shortcut = store.add(AppShortcut())
                            selectionID = shortcut.id
                        } label: {
                            Image(systemName: "plus")
                        }
                        .help("Add shortcut")
                        Button {
                            duplicateSelection()
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .disabled(selectionID == nil)
                        .help("Duplicate shortcut")
                    }
                }
            }
        } detail: {
            if let selectionID, let binding = store.binding(for: selectionID) {
                AppShortcutEditorView(shortcut: binding) {
                    store.remove(binding.wrappedValue)
                    self.selectionID = nil
                }
            } else {
                Text("Select a shortcut")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func row(for shortcut: AppShortcut) -> some View {
        HStack {
            Image(systemName: shortcut.isURL ? "link" : "arrow.right.square")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.name.isEmpty ? "Untitled" : shortcut.name)
                    .lineLimit(1)
                if shortcut.isURL, let urlString = shortcut.urlString, !urlString.isEmpty {
                    Text(urlString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if !shortcut.isURL, let bundleID = shortcut.bundleIdentifier, !bundleID.isEmpty {
                    Text(bundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let shortcut = KeyboardShortcuts.getShortcut(for: HotkeyManager.appJumpName(for: shortcut.id)) {
                Text(shortcut.description)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func duplicateSelection() {
        guard let selectionID, let shortcut = store.appShortcut(withID: selectionID) else { return }
        self.selectionID = store.duplicate(shortcut).id
    }
}
