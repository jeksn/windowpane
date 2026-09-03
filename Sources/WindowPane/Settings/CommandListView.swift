import WindowPaneCore
import SwiftUI
import KeyboardShortcuts

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
                    ForEach(store.commands) { command in
                        HStack {
                            Text(command.name.isEmpty ? "Untitled" : command.name)
                                .lineLimit(1)
                            Spacer()
                            if let shortcut = KeyboardShortcuts.getShortcut(for: HotkeyManager.name(for: command.id)) {
                                Text(shortcut.description)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onMove { store.move(from: $0, to: $1) }
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

    private func addCommand() {
        var counter = store.commands.count + 1
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
