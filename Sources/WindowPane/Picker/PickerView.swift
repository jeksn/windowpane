import WindowPaneCore
import SwiftUI
import KeyboardShortcuts

struct PickerView: View {
    @ObservedObject var viewModel: PickerViewModel
    let onSelect: (WindowCommand) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Type a command name", text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .focused($isFocused)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            if viewModel.filtered.isEmpty {
                Text("No matching commands")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { index, command in
                                PickerRowView(command: command, isSelected: index == viewModel.selectedIndex)
                                    .id(command.id)
                                    .onTapGesture { onSelect(command) }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: viewModel.selectedIndex) { index in
                        if let command = viewModel.filtered[safe: index] {
                            proxy.scrollTo(command.id, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: 560, height: 380)
        .background(.regularMaterial)
        .onAppear { isFocused = true }
        .onChange(of: viewModel.focusToken) { _ in isFocused = true }
        .onExitCommand { PickerController.shared.close() }
    }
}

struct PickerRowView: View {
    let command: WindowCommand
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "macwindow")
                .foregroundStyle(.secondary)
            Text(command.name.isEmpty ? "Untitled" : command.name)
                .lineLimit(1)
            Spacer()
            if let shortcut = KeyboardShortcuts.getShortcut(for: HotkeyManager.name(for: command.id)) {
                Text(shortcut.description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.25) : Color.clear)
        )
        .padding(.horizontal, 6)
    }
}
