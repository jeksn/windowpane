import WindowPaneCore
import Foundation

final class PickerViewModel: ObservableObject {
    @Published var query = "" {
        didSet { selectedIndex = 0 }
    }
    @Published var selectedIndex = 0
    @Published var focusToken = UUID()

    var commands: [WindowCommand] = []

    func reset() {
        query = ""
        selectedIndex = 0
        focusToken = UUID()
    }

    var filtered: [WindowCommand] {
        FuzzyMatch.ranked(commands, query: query) { $0.name }
    }

    func moveSelection(_ delta: Int) {
        let count = filtered.count
        guard count > 0 else { return }
        selectedIndex = (selectedIndex + delta + count) % count
    }

    func selectedCommand() -> WindowCommand? {
        filtered[safe: selectedIndex]
    }
}
