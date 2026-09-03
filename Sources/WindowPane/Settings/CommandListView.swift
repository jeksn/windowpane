import SwiftUI
import KeyboardShortcuts
import WindowPaneCore

struct CommandListView: View {
    @EnvironmentObject private var store: CommandStore
    @State private var selectionID: UUID?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text("Commands")
                        .font(.headline)
                    Spacer()
                    Button {
                        addCommand()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        duplicateSelection()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .disabled(selectionID == nil)
                    Button {
                        removeSelection()
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(selectionID == nil)
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

                List(selection: $selectionID) {
                    Section {
                        ForEach(store.defaultCommands) { command in
                            row(for: command)
                        }
                    } header: {
                        HStack {
                            Text("Defaults")
                            Spacer()
                            Button("Restore Defaults") {
                                store.restoreDefaults()
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                        }
                    }
                    Section("Custom") {
                        ForEach(store.customCommands) { command in
                            row(for: command)
                        }
                        .onMove { store.moveCustom(from: $0, to: $1) }
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(width: 260)

            Divider()

            if let selectionID, let binding = store.binding(for: selectionID) {
                CommandEditorView(command: binding)
            } else {
                Text("Select a command")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func row(for command: WindowCommand) -> some View {
        HStack {
            Text(command.name.isEmpty ? "Untitled" : command.name)
                .lineLimit(1)
            Spacer()
            if command.showInMenuBar {
                Image(systemName: "menubar.dock.rectangle")
                    .foregroundStyle(.secondary)
                    .help("Shown in menu bar")
            }
            if let shortcut = KeyboardShortcuts.getShortcut(for: HotkeyManager.name(for: command.id)) {
                Text(shortcutDescription(shortcut))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func shortcutDescription(_ shortcut: KeyboardShortcuts.Shortcut) -> String {
        shortcut.description
    }

    private func addCommand() {
        var counter = store.customCommands.count + 1
        var name = "New Command"
        while store.commands.contains(where: { $0.name == name }) {
            counter += 1
            name = "New Command \(counter)"
        }
        let command = WindowCommand(name: name, width: .percent(50), height: .percent(50), anchor: .center)
        store.add(command)
        selectionID = command.id
    }

    private func duplicateSelection() {
        guard let selectionID, let command = store.command(withID: selectionID) else { return }
        self.selectionID = store.duplicate(command).id
    }

    private func removeSelection() {
        guard let selectionID, let command = store.command(withID: selectionID) else { return }
        store.remove(command)
        self.selectionID = nil
    }
}
