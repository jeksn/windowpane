import WindowPaneCore
import Foundation
import KeyboardShortcuts

final class HotkeyManager {
    static let shared = HotkeyManager()

    static let restore = KeyboardShortcuts.Name("restoreLastGeometry")
    static let openPicker = KeyboardShortcuts.Name("openQuickPicker")

    private var registeredCommandIDs = Set<UUID>()
    private var fixedNamesRegistered = false

    func registerAll(for store: CommandStore) {
        for command in store.commands {
            register(command)
        }

        guard !fixedNamesRegistered else { return }
        fixedNamesRegistered = true
        KeyboardShortcuts.onKeyUp(for: Self.restore) {
            CommandApplier.shared.restore()
        }
        KeyboardShortcuts.onKeyUp(for: Self.openPicker) {
            PickerController.shared.toggle()
        }
    }

    func register(_ command: WindowCommand) {
        guard !registeredCommandIDs.contains(command.id) else { return }
        registeredCommandIDs.insert(command.id)

        let id = command.id
        KeyboardShortcuts.onKeyUp(for: Self.name(for: id)) {
            guard let command = CommandStore.shared.command(withID: id) else { return }
            CommandApplier.shared.apply(command)
        }
    }

    static func name(for id: UUID) -> KeyboardShortcuts.Name {
        KeyboardShortcuts.Name("command.\(id.uuidString)")
    }
}
