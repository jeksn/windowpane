import ApplicationServices

enum Accessibility {
    static var isTrusted: Bool { AXIsProcessTrusted() }

    @discardableResult
    static func ensureTrusted(prompt: Bool = false) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static var systemSettingsURL: URL {
        URL(string: "x-apple.systemsettings:com.apple.preference.security?Privacy_Accessibility")!
    }
}
