import WindowPaneCore
import Foundation
import SwiftUI
import KeyboardShortcuts

final class CommandStore: ObservableObject {
    static let shared = CommandStore()

    @Published private(set) var commands: [WindowCommand]

    private init() {
        if let loaded = Self.load() {
            commands = loaded
        } else {
            commands = WindowCommand.seeds
            Self.save(commands)
        }
    }

    func command(withID id: UUID) -> WindowCommand? {
        commands.first { $0.id == id }
    }

    func command(named name: String) -> WindowCommand? {
        commands.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    func add(_ command: WindowCommand) {
        commands.append(command)
        save()
        HotkeyManager.shared.register(command)
    }

    func update(_ command: WindowCommand) {
        guard let index = commands.firstIndex(where: { $0.id == command.id }) else { return }
        commands[index] = command
        save()
    }

    @discardableResult
    func duplicate(_ command: WindowCommand) -> WindowCommand {
        var copy = command
        copy.id = UUID()
        copy.name = uniqueName(basedOn: command.name)
        if let index = commands.firstIndex(where: { $0.id == command.id }) {
            commands.insert(copy, at: index + 1)
        } else {
            commands.append(copy)
        }
        save()
        HotkeyManager.shared.register(copy)
        return copy
    }

    func remove(_ command: WindowCommand) {
        commands.removeAll { $0.id == command.id }
        KeyboardShortcuts.setShortcut(nil, for: HotkeyManager.name(for: command.id))
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        commands.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func binding(for id: UUID) -> Binding<WindowCommand>? {
        guard commands.contains(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.command(withID: id) ?? WindowCommand() },
            set: { self.update($0) }
        )
    }

    private func save() {
        Self.save(commands)
    }

    private func uniqueName(basedOn name: String) -> String {
        var candidate = "\(name) copy"
        var counter = 2
        while commands.contains(where: { $0.name == candidate }) {
            candidate = "\(name) copy \(counter)"
            counter += 1
        }
        return candidate
    }

    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WindowPane", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("commands.json")
    }

    private static func load() -> [WindowCommand]? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode([WindowCommand].self, from: data)
    }

    private static func save(_ commands: [WindowCommand]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(commands) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
