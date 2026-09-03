public enum FuzzyMatch {
    public static func score(query: String, target: String) -> Int? {
        let queryChars = Array(query.lowercased())
        let targetChars = Array(target.lowercased())
        guard !queryChars.isEmpty else { return 0 }
        guard !targetChars.isEmpty else { return nil }

        var total = 0
        var searchIndex = 0
        var consecutive = false

        for char in queryChars {
            var matched = false
            while searchIndex < targetChars.count {
                if targetChars[searchIndex] == char {
                    matched = true
                    total += consecutive ? 6 : 2
                    if searchIndex == 0 { total += 4 }
                    consecutive = true
                    searchIndex += 1
                    break
                }
                searchIndex += 1
                consecutive = false
            }
            guard matched else { return nil }
        }
        return total
    }

    public static func ranked<T>(_ items: [T], query: String, text: (T) -> String) -> [T] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return items }
        return items
            .compactMap { item -> (T, Int)? in
                score(query: query, target: text(item)).map { (item, $0) }
            }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return text(lhs.0).localizedCaseInsensitiveCompare(text(rhs.0)) == .orderedAscending
            }
            .map(\.0)
    }
}
