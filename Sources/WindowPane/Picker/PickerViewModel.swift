import Foundation
import KeyboardShortcuts
import WindowPaneCore

struct PickerItem: Identifiable {
    let title: String
    let hotkeyName: KeyboardShortcuts.Name
    let command: WindowCommand

    var id: String { hotkeyName.rawValue }
}

final class PickerViewModel: ObservableObject {
    @Published var query = "" {
        didSet { selectedIndex = 0 }
    }
    @Published var selectedIndex = 0
    @Published var focusToken = UUID()

    var items: [PickerItem] = []

    func reset() {
        query = ""
        selectedIndex = 0
        focusToken = UUID()
    }

    var filtered: [PickerItem] {
        FuzzyMatch.ranked(items, query: query) { $0.title }
    }

    func moveSelection(_ delta: Int) {
        let count = filtered.count
        guard count > 0 else { return }
        selectedIndex = (selectedIndex + delta + count) % count
    }

    func selectedItem() -> PickerItem? {
        filtered[safe: selectedIndex]
    }
}
