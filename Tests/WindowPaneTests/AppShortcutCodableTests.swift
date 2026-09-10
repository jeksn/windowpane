import Foundation
import WindowPaneCore

enum AppShortcutCodableTests {
    static func runAll(_ t: TestRunner) {
        t.run("AppShortcut.appRoundTrip") {
            let shortcut = AppShortcut(
                name: "Safari",
                isURL: false,
                bundleIdentifier: "com.apple.Safari",
                bundleURL: URL(fileURLWithPath: "/Applications/Safari.app"),
                urlString: nil
            )
            let data = try JSONEncoder().encode(shortcut)
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: data)
            t.check(decoded == shortcut, "round trip mismatch")
        }

        t.run("AppShortcut.urlRoundTrip") {
            let shortcut = AppShortcut(
                name: "Obsidian",
                isURL: true,
                bundleIdentifier: nil,
                bundleURL: nil,
                urlString: "obsidian://open?vault=Main&file=Work/Todo"
            )
            let data = try JSONEncoder().encode(shortcut)
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: data)
            t.check(decoded == shortcut, "round trip mismatch")
            t.check(decoded.url != nil, "url should be non-nil")
        }

        t.run("AppShortcut.nilBundleURLRoundTrip") {
            let shortcut = AppShortcut(
                name: "Custom",
                isURL: false,
                bundleIdentifier: "com.example.custom",
                bundleURL: nil,
                urlString: nil
            )
            let data = try JSONEncoder().encode(shortcut)
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: data)
            t.check(decoded == shortcut, "round trip mismatch")
            t.check(decoded.bundleURL == nil, "bundleURL should be nil")
        }

        t.run("AppShortcut.encodingShape") {
            let shortcut = AppShortcut(
                name: "Finder",
                isURL: false,
                bundleIdentifier: "com.apple.finder",
                bundleURL: URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app"),
                urlString: nil
            )
            let data = try JSONEncoder().encode(shortcut)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            t.check(json?["name"] as? String == "Finder", "name mismatch")
            t.check(json?["isURL"] as? Bool == false, "isURL mismatch")
            t.check(json?["bundleIdentifier"] as? String == "com.apple.finder", "bundleIdentifier mismatch")
            t.check(json?["bundleURL"] as? String == "file:///System/Library/CoreServices/Finder.app/", "bundleURL mismatch")
        }

        t.run("AppShortcut.decodesMissingFields") {
            let json = #"{"name": "Test"}"#
            let decoded = try JSONDecoder().decode(AppShortcut.self, from: Data(json.utf8))
            t.check(decoded.name == "Test", "name mismatch")
            t.check(decoded.isURL == false, "isURL should default to false")
            t.check(decoded.bundleIdentifier == nil, "bundleIdentifier should default to nil")
            t.check(decoded.bundleURL == nil, "bundleURL should default to nil")
            t.check(decoded.urlString == nil, "urlString should default to nil")
            t.check(decoded.id != UUID(), "id should be generated")
        }

        t.run("AppShortcut.validity") {
            let withID = AppShortcut(name: "A", bundleIdentifier: "com.a", bundleURL: nil)
            t.check(withID.isValid, "shortcut with bundle identifier should be valid")

            let withURL = AppShortcut(name: "B", bundleIdentifier: nil, bundleURL: URL(fileURLWithPath: "/B.app"))
            t.check(withURL.isValid, "shortcut with bundle URL should be valid")

            let empty = AppShortcut(name: "C", bundleIdentifier: "", bundleURL: nil)
            t.check(!empty.isValid, "shortcut with empty identifier and no URL should be invalid")

            let link = AppShortcut(name: "D", isURL: true, bundleIdentifier: nil, bundleURL: nil, urlString: "https://example.com")
            t.check(link.isValid, "URL shortcut should be valid")

            let badLink = AppShortcut(name: "E", isURL: true, bundleIdentifier: nil, bundleURL: nil, urlString: "")
            t.check(!badLink.isValid, "empty URL should be invalid")
        }
    }
}
