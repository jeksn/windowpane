import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

public enum AppSettings {
    public static let gapKey = "edgeGap"

    public static var gap: Double {
        UserDefaults.standard.double(forKey: gapKey)
    }
}
