import Foundation
import WindowPaneCore

enum AppShortcutCodableTests {
    static func runAll(_ t: TestRunner) {
        t.run("AppShortcut.roundTrip") {
            let shortcut = AppShortcut(
                name: "Safari",
                bundleIdentifier: "com.apple.Safari",
                bundleURL: URL(fileURLWithPath: "/Applications/Safari.app")
            )
            let data = try JSONEncoder().encode(shortcut)
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: data)
            t.check(decoded == shortcut, "round trip mismatch")
        }

        t.run("AppShortcut.nilBundleURLRoundTrip") {
            let shortcut = AppShortcut(
                name: "Custom",
                bundleIdentifier: "com.example.custom",
                bundleURL: nil
            )
            let data = try JSONEncoder().encode(shortcut)
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: data)
            t.check(decoded == shortcut, "round trip mismatch")
            t.check(decoded.bundleURL == nil, "bundleURL should be nil")
        }

        t.run("AppShortcut.encodingShape") {
            let shortcut = AppShortcut(
                name: "Finder",
                bundleIdentifier: "com.apple.finder",
                bundleURL: URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app")
            )
            let data = try JSONEncoder().encode(shortcut)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            t.check(json?["name"] as? String == "Finder", "name mismatch")
            t.check(json?["bundleIdentifier"] as? String == "com.apple.finder", "bundleIdentifier mismatch")
            t.check(json?["bundleURL"] as? String == "file:///System/Library/CoreServices/Finder.app/", "bundleURL mismatch")
        }

        t.run("AppShortcut.decodesMissingFields") {
            let json = #"{"name": "Test"}"#
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: Data(json.utf8))
            t.check(decoded.name == "Test", "name mismatch")
            t.check(decoded.bundleIdentifier == nil, "bundleIdentifier should default to nil")
            t.check(decoded.bundleURL == nil, "bundleURL should default to nil")
            t.check(decoded.id != UUID(), "id should be generated")
        }

        t.run("AppShortcut.validity") {
            let withID = AppShortcut(name: "A", bundleIdentifier: "com.a", bundleURL: nil)
            t.check(withID.isValid, "shortcut with bundle identifier should be valid")

            let withURL = AppShortcut(name: "B", bundleIdentifier: nil, bundleURL: URL(fileURLWithPath: "/B.app"))
            t.check(withURL.isValid, "shortcut with bundle URL should be valid")

            let empty = AppShortcut(name: "C", bundleIdentifier: "", bundleURL: nil)
            t.check(!empty.isValid, "shortcut with empty identifier and no URL should be invalid")
        }
    }
}
